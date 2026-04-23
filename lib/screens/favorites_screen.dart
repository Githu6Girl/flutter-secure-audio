import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/favorite_service.dart';
import '../services/biometric_service.dart';
import '../widgets/glass_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final BiometricService _biometricService = BiometricService();

  Future<void> _confirmDeleteFavorite(Track track) async {
    // LE PDF DEMANDE L'EMPREINTE POUR SUPPRIMER : LA VOICI !
    final isAuthenticated = await _biometricService.authenticateForAction(
      'Authentifiez-vous pour supprimer ce favori',
    );

    if (isAuthenticated && mounted) {
      context.read<FavoriteService>().removeFromFavorites(track.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Favori supprimé avec succès', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFF87171).withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteService = context.watch<FavoriteService>();

    return Scaffold(
      backgroundColor: Colors.transparent, // Laisse voir l'AppBackground
      appBar: AppBar(
        title: const Text('Mes Favoris', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: favoriteService.favorites.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border, size: 64, color: Colors.white30),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun favori',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des pistes depuis le lecteur',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoriteService.favorites.length,
        itemBuilder: (context, index) {
          final track = favoriteService.favorites[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors:[Color(0xFFEC4899), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow:[
                      BoxShadow(color: const Color(0xFFEC4899).withOpacity(0.3), blurRadius: 10),
                    ],
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 24),
                ),
                title: Text(
                  track.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  track.artist,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFF87171), size: 28),
                  onPressed: () => _confirmDeleteFavorite(track), // Appelle la vérification biométrique
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}