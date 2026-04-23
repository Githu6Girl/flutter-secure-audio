import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../services/audio_service.dart' as audio_svc;
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final ApiService _apiService = ApiService();
  late AudioPlayer _audioPlayer;

  Map<String, List<Track>> _playlists = {};
  String? _selectedCategory;
  Track? _currentTrack;
  bool _isLoading = true;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  audio_svc.RepeatMode _repeatMode = audio_svc.RepeatMode.all;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadPlaylists();
    _setupAudioListener();
  }

  void _setupAudioListener() {
    _audioPlayer.playbackEventStream.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = _audioPlayer.playing;
          _currentPosition = _audioPlayer.position;
        });
      }
    });
    _audioPlayer.durationStream.listen((duration) {
      if (mounted) setState(() => _totalDuration = duration ?? Duration.zero);
    });
  }

  Future<void> _loadPlaylists() async {
    try {
      final playlists = await _apiService.fetchAudioByCategory();
      setState(() {
        _playlists = playlists;
        _selectedCategory = playlists.keys.isNotEmpty ? playlists.keys.first : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playTrack(Track track) async {
    try {
      setState(() => _currentTrack = track);
      await _audioPlayer.setUrl(track.url);
      await _audioPlayer.play();
    } catch (e) {
      // Erreur silencieuse ou snackbar
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) await _audioPlayer.pause();
    else await _audioPlayer.play();
  }

  Future<void> _skipNext() async {
    if (_selectedCategory != null && _currentTrack != null) {
      final tracks = _playlists[_selectedCategory]!;
      final currentIndex = tracks.indexWhere((t) => t.id == _currentTrack!.id);
      if (currentIndex != -1 && currentIndex < tracks.length - 1) {
        await _playTrack(tracks[currentIndex + 1]);
      }
    }
  }

  Future<void> _skipPrevious() async {
    if (_selectedCategory != null && _currentTrack != null) {
      final tracks = _playlists[_selectedCategory]!;
      final currentIndex = tracks.indexWhere((t) => t.id == _currentTrack!.id);
      if (currentIndex > 0) {
        await _playTrack(tracks[currentIndex - 1]);
      }
    }
  }

  void _toggleRepeat() {
    setState(() {
      switch (_repeatMode) {
        case audio_svc.RepeatMode.off: _repeatMode = audio_svc.RepeatMode.one; break;
        case audio_svc.RepeatMode.one: _repeatMode = audio_svc.RepeatMode.all; break;
        case audio_svc.RepeatMode.all: _repeatMode = audio_svc.RepeatMode.off; break;
      }
    });
  }

  IconData _getRepeatIcon() {
    switch (_repeatMode) {
      case audio_svc.RepeatMode.off: return Icons.repeat;
      case audio_svc.RepeatMode.one: return Icons.repeat_one;
      case audio_svc.RepeatMode.all: return Icons.repeat_on;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A1A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      );
    }

    final favoriteService = context.watch<FavoriteService>();
    final isFavorite = _currentTrack != null && favoriteService.isFavorite(_currentTrack!.id);

    return Scaffold(
      backgroundColor: Colors.transparent, // Pour laisser voir l'AppBackground depuis MainScreen
      appBar: AppBar(
        title: const Text('Lecteur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children:[
          // Sélecteur de catégories "Glass"
          if (_playlists.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _playlists.keys.map((category) {
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6366F1).withOpacity(0.3) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6366F1) : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 10),

          // Liste des pistes
          Expanded(
            child: _selectedCategory != null && _playlists[_selectedCategory]!.isNotEmpty
                ? ListView.builder(
              itemCount: _playlists[_selectedCategory]!.length,
              itemBuilder: (context, index) {
                final track = _playlists[_selectedCategory]![index];
                final isCurrentTrack = _currentTrack?.id == track.id;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrentTrack ? Colors.white.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors:[Color(0xFF6366F1), Color(0xFF0EA5E9)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isCurrentTrack && _isPlaying
                          ? const Icon(Icons.bar_chart, color: Colors.white)
                          : const Icon(Icons.music_note, color: Colors.white54),
                    ),
                    title: Text(track.title, style: TextStyle(color: Colors.white, fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal)),
                    subtitle: Text(track.artist, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    trailing: IconButton(
                      icon: Icon(
                        favoriteService.isFavorite(track.id) ? Icons.favorite : Icons.favorite_border,
                        color: favoriteService.isFavorite(track.id) ? const Color(0xFFEC4899) : Colors.white30,
                      ),
                      onPressed: () {
                        if (favoriteService.isFavorite(track.id)) favoriteService.removeFromFavorites(track.id);
                        else favoriteService.addToFavorites(track);
                      },
                    ),
                    onTap: () => _playTrack(track),
                  ),
                );
              },
            )
                : const Center(child: Text('Aucune piste', style: TextStyle(color: Colors.white54))),
          ),

          // Lecteur en cours (Le beau composant en bas)
          if (_currentTrack != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text('EN ÉCOUTE', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, letterSpacing: 2)),
                              const SizedBox(height: 4),
                              Text(_currentTrack!.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(_currentTrack!.artist, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? const Color(0xFFEC4899) : Colors.white),
                          onPressed: () {
                            if (isFavorite) favoriteService.removeFromFavorites(_currentTrack!.id);
                            else favoriteService.addToFavorites(_currentTrack!);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Barre de progression
                    Row(
                      children:[
                        Text('${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                              activeTrackColor: const Color(0xFF6366F1),
                              inactiveTrackColor: Colors.white.withOpacity(0.1),
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              value: _currentPosition.inSeconds.toDouble().clamp(0.0, _totalDuration.inSeconds.toDouble() > 0 ? _totalDuration.inSeconds.toDouble() : 1.0),
                              max: _totalDuration.inSeconds.toDouble() > 0 ? _totalDuration.inSeconds.toDouble() : 1.0,
                              onChanged: (value) => _audioPlayer.seek(Duration(seconds: value.toInt())),
                            ),
                          ),
                        ),
                        Text('${_totalDuration.inMinutes}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                      ],
                    ),
                    // Contrôles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                        IconButton(
                          icon: Icon(_getRepeatIcon(), color: _repeatMode == audio_svc.RepeatMode.off ? Colors.white30 : const Color(0xFF6366F1)),
                          onPressed: _toggleRepeat,
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 30),
                          onPressed: _skipPrevious,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors:[Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                            boxShadow:[BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.4), blurRadius: 15)],
                          ),
                          child: IconButton(
                            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
                            onPressed: _togglePlayPause,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.white, size: 30),
                          onPressed: _skipNext,
                        ),
                        IconButton(
                          icon: const Icon(Icons.shuffle, color: Colors.white30), // UI design, logic to add later if needed
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}