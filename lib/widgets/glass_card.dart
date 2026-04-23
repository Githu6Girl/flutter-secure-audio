import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double width;
  final double? height;
  final double borderRadius;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.width = double.infinity,
    this.height,
    this.borderRadius = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // L'effet de flou
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06), // Transparence du fond
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.12), // Bordure lumineuse
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}