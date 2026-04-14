import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Track {
  final String id;
  final String title;
  final String artist;
  final String category;
  final String url;
  final String? imageUrl;
  final int durationSeconds;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.category,
    required this.url,
    this.imageUrl,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'category': category,
      'url': url,
      'imageUrl': imageUrl,
      'durationSeconds': durationSeconds,
    };
  }

  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      category: map['category'] ?? '',
      url: map['url'] ?? '',
      imageUrl: map['imageUrl'],
      durationSeconds: map['durationSeconds'] ?? 0,
    );
  }
}

class FavoriteService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Track> _favorites = [];
  List<Track> get favorites => _favorites;

  FavoriteService() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      _favorites = snapshot.docs
          .map((doc) => Track.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
    }
  }

  Future<void> addToFavorites(Track track) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(track.id)
          .set(track.toMap());

      _favorites.add(track);
      notifyListeners();
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout aux favoris: $e');
    }
  }

  Future<void> removeFromFavorites(String trackId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(trackId)
          .delete();

      _favorites.removeWhere((track) => track.id == trackId);
      notifyListeners();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du favori: $e');
    }
  }

  bool isFavorite(String trackId) {
    return _favorites.any((track) => track.id == trackId);
  }

  Future<void> refreshFavorites() async {
    await _loadFavorites();
  }
}
