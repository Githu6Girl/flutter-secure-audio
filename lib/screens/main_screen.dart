import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import 'home_screen.dart';
import 'player_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'dart:ui';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens =[
    const HomeScreen(),
    const PlayerScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Note : AppBackground englobe tout, donc les écrans enfants doivent avoir Scaffold(backgroundColor: Colors.transparent)
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A), // Fallback
      body: Stack(
        children:[
          AppBackground(child: _screens[_currentIndex]),

          // Custom Glass Bottom Navigation Bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A1A).withOpacity(0.8),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    currentIndex: _currentIndex,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: const Color(0xFF8B5CF6),
                    unselectedItemColor: Colors.white.withOpacity(0.4),
                    onTap: (index) => setState(() => _currentIndex = index),
                    items: const[
                      BottomNavigationBarItem(icon: Icon(Icons.space_dashboard_outlined), activeIcon: Icon(Icons.space_dashboard), label: 'Stats'),
                      BottomNavigationBarItem(icon: Icon(Icons.music_note_outlined), activeIcon: Icon(Icons.music_note), label: 'Lecteur'),
                      BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Favoris'),
                      BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Paramètres'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}