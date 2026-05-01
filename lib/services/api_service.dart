import 'package:dio/dio.dart';
import 'favorite_service.dart';

class ApiService {
  final Dio _dio = Dio();
  Map<String, List<Track>>? _cachedTracks;

  Future<Map<String, List<Track>>> fetchAudioByCategory() async {
    if (_cachedTracks != null) return _cachedTracks!;

    try {
      // 1. TÉLÉCHARGER LES VRAIS NOMS DES SOURATES (en français)
      final suwarResponse = await _dio.get('https://mp3quran.net/api/v3/suwar?language=fr');
      Map<int, String> surahNames = {};
      for (var s in suwarResponse.data['suwar']) {
        surahNames[s['id']] = s['name'];
      }

      // 2. TÉLÉCHARGER LES PISTES AUDIO
      final response = await _dio.get('https://mp3quran.net/api/v3/reciters?language=fr');
      Map<String, List<Track>> categorizedTracks = {};
      final List reciters = response.data['reciters'];

      for (var reciter in reciters.take(4)) {
        String reciterName = reciter['name'];
        var moshaf = reciter['moshaf'][0];
        String server = moshaf['server'];
        String surahListStr = moshaf['surah_list'];

        List<Track> tracks =[];
        List<String> surahs = surahListStr.split(',');

        for (var surahIdStr in surahs.take(15)) {
          if (surahIdStr.isEmpty) continue;

          int surahId = int.parse(surahIdStr);
          String formatId = surahId.toString().padLeft(3, '0');

          tracks.add(Track(
            id: '${reciter['id']}_$surahId',
            title: surahNames[surahId] ?? 'Sourate $surahId', // VRAI NOM APPLIQUÉ ICI !
            artist: reciterName,
            category: reciterName,
            url: '$server$formatId.mp3',
            durationSeconds: 0,
          ));
        }
        if (tracks.isNotEmpty) categorizedTracks[reciterName] = tracks;
      }
      _cachedTracks = categorizedTracks;
      return categorizedTracks;

    } catch (e) {
      return _getFallbackData(); // Roue de secours anti-crash
    }
  }

  Map<String, List<Track>> _getFallbackData() {
    return {
      'Abdul Baset':[
        Track(id: 'fb1', title: 'Al-Fatiha', artist: 'Abdul Baset', category: 'Abdul Baset', url: 'https://server7.mp3quran.net/basit/001.mp3', durationSeconds: 0),
        Track(id: 'fb2', title: 'Al-Baqarah', artist: 'Abdul Baset', category: 'Abdul Baset', url: 'https://server7.mp3quran.net/basit/002.mp3', durationSeconds: 0),
      ],
      'Al-Sudais':[
        Track(id: 'fb4', title: 'Al-Fatiha', artist: 'Al-Sudais', category: 'Al-Sudais', url: 'https://server11.mp3quran.net/sds/001.mp3', durationSeconds: 0),
        Track(id: 'fb5', title: 'Yasin', artist: 'Al-Sudais', category: 'Al-Sudais', url: 'https://server11.mp3quran.net/sds/036.mp3', durationSeconds: 0),
      ],
    };
  }
}