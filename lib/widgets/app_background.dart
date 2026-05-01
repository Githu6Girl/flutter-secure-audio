import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:[
            Color(0xFF1A050A), // Presque noir avec reflet bordeaux
            Color(0xFF3D0C1A), // Bordeaux foncé
            Color(0xFF24040E), // Rouge très sombre
            Color(0xFF110005), // Noir bordeaux
          ],
          stops:[0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}