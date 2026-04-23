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
            Color(0xFF0A0A1A), // Noir bleuté profond
            Color(0xFF0D1B3E), // Bleu marine
            Color(0xFF0A1628), // Bleu très sombre
            Color(0xFF06101E), // Presque noir
          ],
          stops:[0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}