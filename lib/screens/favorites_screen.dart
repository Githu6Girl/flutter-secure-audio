import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorite_service.dart';
import '../services/biometric_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final BiometricService _biometricService = BiometricService();

  Future<void> _confirmDeleteFavorite(Track track) async {
    final isAuthenticated = await _biometricService.authenticateForAction(
      'Authentifiez-vous pour supprimer ce favori',
    );

    if (isAuthenticated && mounted) {
      context.read<FavoriteService>().removeFromFavorites(track.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favori supprimé')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteService = context.watch<FavoriteService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
      ),
      body: SafeArea(
        child: favoriteService.favorites.isEmpty
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun favori',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajoutez des pistes à vos favoris',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
            : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: favoriteService.favorites.length,
              itemBuilder: (context, index) {
                final track = favoriteService.favorites[index];

                return Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.music_note,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(track.title),
                    subtitle: Text(track.artist),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDeleteFavorite(track);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Supprimer'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
