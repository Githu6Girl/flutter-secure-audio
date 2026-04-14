import 'package:dio/dio.dart';
import 'favorite_service.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String baseUrl = 'https://quran.yousefheiba.com/api/v3';

  Future<Map<String, List<Track>>> fetchAudioByCategory() async {
    try {
      final response = await _dio.get('$baseUrl/chapters');
      
      Map<String, List<Track>> categorizedTracks = {};
      
      if (response.statusCode == 200) {
        final chapters = response.data['chapters'] as List?;
        
        if (chapters != null) {
          for (var chapter in chapters) {
            final categoryName = chapter['name'] ?? 'Unknown';
            final categoryTracks = await _fetchTracksForChapter(chapter['id']);
            categorizedTracks[categoryName] = categoryTracks;
          }
        }
      }
      
      return categorizedTracks;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données: $e');
    }
  }

  Future<List<Track>> _fetchTracksForChapter(int chapterId) async {
    try {
      final response = await _dio.get('$baseUrl/chapters/$chapterId/translations/1');
      
      List<Track> tracks = [];
      
      if (response.statusCode == 200) {
        final translations = response.data['chapter'] as Map?;
        
        if (translations != null && translations['verses'] != null) {
          for (var verse in translations['verses']) {
            tracks.add(Track(
              id: '${chapterId}_${verse['id']}',
              title: 'Verse ${verse['verse_number']}',
              artist: 'Quran',
              category: 'Quran Chapter $chapterId',
              url: verse['audio']['url'] ?? '',
              imageUrl: null,
              durationSeconds: 0,
            ));
          }
        }
      }
      
      return tracks;
    } catch (e) {
      return [];
    }
  }

  Future<List<Track>> searchTracks(String query) async {
    try {
      // Implement search functionality based on API
      return [];
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }
}
