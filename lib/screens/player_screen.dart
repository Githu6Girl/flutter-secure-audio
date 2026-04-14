import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../services/audio_service.dart' as audio_svc;

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
  
  // Using the prefix to avoid conflict with Flutter's internal RepeatMode
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
      if (mounted) {
        setState(() => _totalDuration = duration ?? Duration.zero);
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _playTrack(Track track) async {
    try {
      setState(() => _currentTrack = track);
      await _audioPlayer.setUrl(track.url);
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de lecture: $e')),
        );
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> _skipNext() async {
    if (_selectedCategory != null && _playlists.isNotEmpty && _currentTrack != null) {
      final tracks = _playlists[_selectedCategory]!;
      final currentIndex = tracks.indexWhere((t) => t.id == _currentTrack!.id);
      if (currentIndex != -1 && currentIndex < tracks.length - 1) {
        await _playTrack(tracks[currentIndex + 1]);
      }
    }
  }

  Future<void> _skipPrevious() async {
    if (_selectedCategory != null && _playlists.isNotEmpty && _currentTrack != null) {
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
        case audio_svc.RepeatMode.off:
          _repeatMode = audio_svc.RepeatMode.one;
          break;
        case audio_svc.RepeatMode.one:
          _repeatMode = audio_svc.RepeatMode.all;
          break;
        case audio_svc.RepeatMode.all:
          _repeatMode = audio_svc.RepeatMode.off;
          break;
      }
    });
  }

  String _getRepeatIcon() {
    switch (_repeatMode) {
      case audio_svc.RepeatMode.off:
        return '↻';
      case audio_svc.RepeatMode.one:
        return '↻¹';
      case audio_svc.RepeatMode.all:
        return '↻∞';
      default:
        return '↻';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final favoriteService = context.watch<FavoriteService>();
    final isFavorite =
        _currentTrack != null && favoriteService.isFavorite(_currentTrack!.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecteur'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category selector
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
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Tracks list
            Expanded(
              child: _selectedCategory != null &&
                      _playlists[_selectedCategory]!.isNotEmpty
                  ? ListView.builder(
                    itemCount: _playlists[_selectedCategory]!.length,
                    itemBuilder: (context, index) {
                      final track = _playlists[_selectedCategory]![index];
                      final isCurrentTrack = _currentTrack?.id == track.id;

                      return ListTile(
                        leading: isCurrentTrack
                            ? SizedBox(
                              width: 40,
                              child: Icon(
                                _isPlaying
                                    ? Icons.volume_up
                                    : Icons.play_arrow,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                            : const SizedBox(width: 40),
                        title: Text(
                          track.title,
                          style: TextStyle(
                            fontWeight: isCurrentTrack
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isCurrentTrack
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                        ),
                        subtitle: Text(track.artist),
                        trailing: IconButton(
                          icon: Icon(
                            favoriteService.isFavorite(track.id)
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: favoriteService.isFavorite(track.id) 
                                ? Colors.red 
                                : null,
                          ),
                          onPressed: () {
                            if (favoriteService.isFavorite(track.id)) {
                              favoriteService.removeFromFavorites(track.id);
                            } else {
                              favoriteService.addToFavorites(track);
                            }
                          },
                        ),
                        onTap: () => _playTrack(track),
                      );
                    },
                  )
                  : const Center(
                    child: Text('Aucune piste disponible'),
                  ),
            ),

            // Now playing section
            if (_currentTrack != null)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'En écoute',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentTrack!.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentTrack!.artist,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),

                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                            ),
                            child: Slider(
                              value: _currentPosition.inSeconds.toDouble().clamp(
                                0.0, 
                                _totalDuration.inSeconds.toDouble()
                              ),
                              max: _totalDuration.inSeconds.toDouble() > 0 
                                  ? _totalDuration.inSeconds.toDouble() 
                                  : 1.0,
                              onChanged: (value) {
                                _audioPlayer.seek(
                                  Duration(seconds: value.toInt()),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                Text(
                                  '${_totalDuration.inMinutes}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Player controls
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Text(
                              _getRepeatIcon(),
                              style: TextStyle(
                                fontSize: 18,
                                color: _repeatMode == audio_svc.RepeatMode.off
                                    ? Colors.grey
                                    : Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: _toggleRepeat,
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            onPressed: _skipPrevious,
                            iconSize: 32,
                          ),
                          FloatingActionButton(
                            onPressed: _togglePlayPause,
                            child: Icon(
                              _isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            onPressed: _skipNext,
                            iconSize: 32,
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              color: isFavorite
                                  ? Colors.red
                                  : null,
                            ),
                            onPressed: () {
                              if (isFavorite) {
                                favoriteService
                                    .removeFromFavorites(_currentTrack!.id);
                              } else {
                                favoriteService.addToFavorites(_currentTrack!);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}