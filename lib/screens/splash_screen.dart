import 'package:flutter/material.dart';
import '../widgets/app_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/'); // Retourne vers la porte biométrique ou auth
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors:[Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow:[
                    BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.5), blurRadius: 30)
                  ],
                ),
                child: const Icon(Icons.waves, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'Mawja',
                style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -1),
              ),
              const SizedBox(height: 8),
              Text(
                'AUDIO EXPERIENCE', // <-- Corrigé ici (directement en majuscules)
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, letterSpacing: 2),
              ),
              const SizedBox(height: 60),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)), strokeWidth: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}