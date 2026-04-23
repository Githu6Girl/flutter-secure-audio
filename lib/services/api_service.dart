import 'package:dio/dio.dart';
import 'favorite_service.dart';

class ApiService {
  final Dio _dio = Dio();
  Map<String, List<Track>>? _cachedTracks;

  Future<Map<String, List<Track>>> fetchAudioByCategory() async {
    // Si déjà chargé, on renvoie directement
    if (_cachedTracks != null) {
      return _cachedTracks!;
    }

    try {
      // API officielle, rapide et 100% gratuite
      final response = await _dio.get('https://mp3quran.net/api/v3/reciters?language=fr');

      Map<String, List<Track>> categorizedTracks = {};
      final List reciters = response.data['reciters'];

      // On charge les 4 premiers récitateurs
      for (var reciter in reciters.take(4)) {
        String reciterName = reciter['name'];
        var moshaf = reciter['moshaf'][0];
        String server = moshaf['server'];
        String surahListStr = moshaf['surah_list'];

        List<Track> tracks =[];
        List<String> surahs = surahListStr.split(',');

        // On prend les 10 premières sourates par récitateur pour que ce soit instantané
        for (var surahIdStr in surahs.take(10)) {
          if (surahIdStr.isEmpty) continue;

          int surahId = int.parse(surahIdStr);
          // Format MP3 (ex: "001.mp3", "002.mp3")
          String formatId = surahId.toString().padLeft(3, '0');
          String audioUrl = '$server$formatId.mp3';

          tracks.add(Track(
            id: '${reciter['id']}_$surahId',
            title: 'Sourate $surahId',
            artist: reciterName,
            category: reciterName,
            url: audioUrl,
            durationSeconds: 0,
          ));
        }

        if (tracks.isNotEmpty) {
          categorizedTracks[reciterName] = tracks;
        }
      }

      _cachedTracks = categorizedTracks;
      return categorizedTracks;

    } catch (e) {
      print('Erreur réseau, activation de la roue de secours: $e');
      // PLAN B : SI L'API PLANTE, ON AFFICHE ÇA (Anti-crash pour la présentation !)
      return _getFallbackData();
    }
  }

  // Fonction de recherche
  Future<List<Track>> searchTracks(String query) async {
    try {
      final allCategories = await fetchAudioByCategory();
      if (query.trim().isEmpty) return [];

      List<Track> searchResults =[];
      final searchTerm = query.toLowerCase();

      for (var tracks in allCategories.values) {
        for (var track in tracks) {
          if (track.title.toLowerCase().contains(searchTerm) ||
              track.artist.toLowerCase().contains(searchTerm)) {
            searchResults.add(track);
          }
        }
      }
      return searchResults;
    } catch (e) {
      return[];
    }
  }

  // --- LES DONNÉES DE SECOURS ---
  Map<String, List<Track>> _getFallbackData() {
    return {
      'Abdul Baset':[
        Track(id: 'fb1', title: 'Al-Fatiha', artist: 'Abdul Baset', category: 'Abdul Baset', url: 'https://server7.mp3quran.net/basit/001.mp3', durationSeconds: 0),
        Track(id: 'fb2', title: 'Al-Baqarah', artist: 'Abdul Baset', category: 'Abdul Baset', url: 'https://server7.mp3quran.net/basit/002.mp3', durationSeconds: 0),
        Track(id: 'fb3', title: 'Al-Kahf', artist: 'Abdul Baset', category: 'Abdul Baset', url: 'https://server7.mp3quran.net/basit/018.mp3', durationSeconds: 0),
      ],
      'Al-Sudais':[
        Track(id: 'fb4', title: 'Al-Fatiha', artist: 'Al-Sudais', category: 'Al-Sudais', url: 'https://server11.mp3quran.net/sds/001.mp3', durationSeconds: 0),
        Track(id: 'fb5', title: 'Yasin', artist: 'Al-Sudais', category: 'Al-Sudais', url: 'https://server11.mp3quran.net/sds/036.mp3', durationSeconds: 0),
        Track(id: 'fb6', title: 'Ar-Rahman', artist: 'Al-Sudais', category: 'Al-Sudais', url: 'https://server11.mp3quran.net/sds/055.mp3', durationSeconds: 0),
      ],
    };
  }
}