import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'favorite_service.dart';

enum RepeatMode { off, one, all }

class AudioService {
  late AudioPlayer _audioPlayer;
  Track? _currentTrack;
  RepeatMode _repeatMode = RepeatMode.all;
  List<Track> _queue = [];
  int _currentIndex = 0;
  int _listeningMinutesToday = 0;

  AudioPlayer get audioPlayer => _audioPlayer;
  Track? get currentTrack => _currentTrack;
  RepeatMode get repeatMode => _repeatMode;
  List<Track> get queue => _queue;
  int get currentIndex => _currentIndex;
  int get listeningMinutesToday => _listeningMinutesToday;

  AudioService() {
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    _audioPlayer.playbackEventStream.listen((event) {
      // Track listening time
      if (_audioPlayer.playing) {
        _updateListeningTime();
      }
    });
  }

  Future<void> playTrack(Track track) async {
    try {
      _currentTrack = track;
      await _audioPlayer.setUrl(track.url);
      await _audioPlayer.play();
    } catch (e) {
      throw Exception('Erreur lors de la lecture: $e');
    }
  }

  Future<void> playPlaylist(List<Track> tracks, int startIndex) async {
    try {
      _queue = tracks;
      _currentIndex = startIndex;
      await playTrack(tracks[startIndex]);
    } catch (e) {
      throw Exception('Erreur lors de la lecture de la playlist: $e');
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> nextTrack() async {
    if (_queue.isEmpty) return;

    int nextIndex = _currentIndex + 1;
    if (nextIndex >= _queue.length) {
      if (_repeatMode == RepeatMode.all) {
        nextIndex = 0;
      } else {
        return;
      }
    }

    _currentIndex = nextIndex;
    await playTrack(_queue[nextIndex]);
  }

  Future<void> previousTrack() async {
    if (_queue.isEmpty) return;

    int prevIndex = _currentIndex - 1;
    if (prevIndex < 0) {
      prevIndex = _queue.length - 1;
    }

    _currentIndex = prevIndex;
    await playTrack(_queue[prevIndex]);
  }

  void toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.off;
        break;
    }
  }

  void _updateListeningTime() {
    _listeningMinutesToday++;
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
