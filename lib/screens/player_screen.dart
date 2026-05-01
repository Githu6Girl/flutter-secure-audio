import 'dart:async'; // Pour le minuteur
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart'; // Pour le partage
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../services/audio_service.dart' as audio_svc;
import '../widgets/glass_card.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final ApiService _apiService = ApiService();
  late AudioPlayer _audioPlayer;
  final TextEditingController _searchController = TextEditingController();

  Map<String, List<Track>> _playlists = {};
  String? _selectedCategory;
  Track? _currentTrack;
  bool _isLoading = true;
  bool _isPlaying = false;
  String _searchQuery = '';
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  audio_svc.RepeatMode _repeatMode = audio_svc.RepeatMode.all;

  // Variables pour le Minuteur de Sommeil
  Timer? _sleepTimer;
  int? _sleepMinutesLeft;

  final Color mainBurgundy = const Color(0xFF800020);
  final Color lightBurgundy = const Color(0xFFC72C48);

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
    } catch (e) {}
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

  // --- FONCTIONNALITÉ PARTAGE ---
  void _shareTrack() {
    if (_currentTrack != null) {
      Share.share('J\'écoute ${_currentTrack!.title} de ${_currentTrack!.artist} sur l\'application Mawja ! 🎵');
    }
  }

  // --- FONCTIONNALITÉ MINUTEUR DE SOMMEIL ---
  void _setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    if (minutes == 0) {
      setState(() => _sleepMinutesLeft = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minuteur désactivé')));
      return;
    }

    setState(() => _sleepMinutesLeft = minutes);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La musique s\'arrêtera dans $minutes minutes')));

    _sleepTimer = Timer(Duration(minutes: minutes), () {
      _audioPlayer.pause();
      setState(() => _sleepMinutesLeft = null);
    });
  }

  void _showSleepTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              const Icon(Icons.mode_night, color: Colors.white, size: 40),
              const SizedBox(height: 16),
              const Text('Minuteur de sommeil', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(title: const Text('Désactiver', style: TextStyle(color: Colors.white)), onTap: () { _setSleepTimer(0); Navigator.pop(context); }),
              ListTile(title: const Text('15 minutes', style: TextStyle(color: Colors.white)), onTap: () { _setSleepTimer(15); Navigator.pop(context); }),
              ListTile(title: const Text('30 minutes', style: TextStyle(color: Colors.white)), onTap: () { _setSleepTimer(30); Navigator.pop(context); }),
              ListTile(title: const Text('60 minutes', style: TextStyle(color: Colors.white)), onTap: () { _setSleepTimer(60); Navigator.pop(context); }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: const Color(0xFF1A050A), body: Center(child: CircularProgressIndicator(color: lightBurgundy)));
    }

    final favoriteService = context.watch<FavoriteService>();
    final isFavorite = _currentTrack != null && favoriteService.isFavorite(_currentTrack!.id);

    List<Track> currentList = [];
    if (_selectedCategory != null && _playlists[_selectedCategory] != null) {
      currentList = _playlists[_selectedCategory]!.where((track) =>
      track.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          track.artist.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Lecteur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children:[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un audio...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: lightBurgundy, width: 1.5)),
              ),
            ),
          ),

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
                      onTap: () {
                        setState(() { _selectedCategory = category; _searchController.clear(); _searchQuery = ''; });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? mainBurgundy.withOpacity(0.5) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? lightBurgundy : Colors.white.withOpacity(0.1)),
                        ),
                        child: Center(child: Text(category, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 10),

          Expanded(
            child: currentList.isNotEmpty
                ? ListView.builder(
              itemCount: currentList.length,
              itemBuilder: (context, index) {
                final track = currentList[index];
                final isCurrentTrack = _currentTrack?.id == track.id;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: isCurrentTrack ? Colors.white.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(gradient: LinearGradient(colors:[mainBurgundy, lightBurgundy]), borderRadius: BorderRadius.circular(10)),
                      child: isCurrentTrack && _isPlaying ? const Icon(Icons.bar_chart, color: Colors.white) : const Icon(Icons.music_note, color: Colors.white54),
                    ),
                    title: Text(track.title, style: TextStyle(color: Colors.white, fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal)),
                    subtitle: Text(track.artist, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                    onTap: () => _playTrack(track),
                  ),
                );
              },
            )
                : Center(child: Text(_searchQuery.isNotEmpty ? 'Aucun résultat' : 'Aucune piste', style: const TextStyle(color: Colors.white54))),
          ),

          if (_currentTrack != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children:[
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
                        // BOUTON MINUTEUR DE SOMMEIL
                        IconButton(
                          icon: Icon(
                            _sleepMinutesLeft != null ? Icons.mode_night : Icons.mode_night_outlined,
                            color: _sleepMinutesLeft != null ? lightBurgundy : Colors.white,
                          ),
                          onPressed: _showSleepTimerDialog,
                        ),
                        // BOUTON PARTAGER
                        IconButton(
                          icon: const Icon(Icons.share_outlined, color: Colors.white),
                          onPressed: _shareTrack,
                        ),
                        // BOUTON FAVORIS
                        IconButton(
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? lightBurgundy : Colors.white),
                          onPressed: () {
                            if (isFavorite) favoriteService.removeFromFavorites(_currentTrack!.id);
                            else favoriteService.addToFavorites(_currentTrack!);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children:[
                        Text('${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                              activeTrackColor: lightBurgundy, inactiveTrackColor: Colors.white.withOpacity(0.1), thumbColor: Colors.white,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                        IconButton(icon: Icon(_getRepeatIcon(), color: _repeatMode == audio_svc.RepeatMode.off ? Colors.white30 : lightBurgundy), onPressed: _toggleRepeat),
                        IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 30), onPressed: _skipPrevious),
                        Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors:[mainBurgundy, lightBurgundy]), boxShadow:[BoxShadow(color: mainBurgundy.withOpacity(0.4), blurRadius: 15)]),
                          child: IconButton(icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32), onPressed: _togglePlayPause),
                        ),
                        IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 30), onPressed: _skipNext),
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
    _sleepTimer?.cancel();
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }
}