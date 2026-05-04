import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'themes/app_theme.dart';
import 'services/auth_service.dart';
import 'services/biometric_service.dart';
import 'services/favorite_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers:[
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<BiometricService>(create: (_) => BiometricService()),
        ChangeNotifierProvider<FavoriteService>(
          create: (_) => FavoriteService(),
        ),
      ],
      child: MaterialApp(
        title: 'Mawja',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Thème Burgundy
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash', // Démarre sur le splash screen (corrige l'écran blanc)
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/': (_) => const BiometricGateScreen(),
          '/auth': (_) => const AuthWrapper(),
          '/home': (_) => const MainScreen(),
          '/login': (_) => const LoginScreen(),
        },
      ),
    );
  }
}

class BiometricGateScreen extends StatefulWidget {
  const BiometricGateScreen({Key? key}) : super(key: key);

  @override
  State<BiometricGateScreen> createState() => _BiometricGateScreenState();
}

class _BiometricGateScreenState extends State<BiometricGateScreen> {
  bool _isChecking = true;
  String? _statusMessage;
  bool _needsConfiguration = false;

  @override
  void initState() {
    super.initState();
    _verifyBiometric();
  }

  Future<void> _verifyBiometric() async {
    setState(() {
      _isChecking = true;
      _needsConfiguration = false;
    });

    final biometricService = context.read<BiometricService>();
    final isSupported = await biometricService.isBiometricAvailable();
    final hasEnrolled = await biometricService.hasEnrolledBiometrics();

    if (!isSupported) {
      if (mounted) Navigator.of(context).pushReplacementNamed('/auth');
      return;
    }

    if (!hasEnrolled) {
      setState(() {
        _isChecking = false;
        _needsConfiguration = true;
        _statusMessage = 'Aucune empreinte configurée.\nVous devez sécuriser votre téléphone pour utiliser Mawja.';
      });
      await biometricService.openBiometricSettings();
      return;
    }

    final isAuthenticated = await biometricService.authenticate();

    if (!isAuthenticated) {
      if (!mounted) return;
      setState(() {
        _isChecking = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Accès refusé', style: TextStyle(color: Colors.white)),
          content: const Text('L\'empreinte digitale est obligatoire pour accéder à l\'application.', style: TextStyle(color: Colors.white70)),
          actions:[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _verifyBiometric();
              },
              child: const Text('Réessayer', style: TextStyle(color: Color(0xFFC72C48), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    await biometricService.playSuccessSound();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A050A),
      body: Center(
        child: _isChecking
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: const[
            CircularProgressIndicator(color: Color(0xFFC72C48)),
            SizedBox(height: 20),
            Text('Vérification de sécurité...', style: TextStyle(color: Colors.white70)),
          ],
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              const Icon(Icons.security, size: 60, color: Color(0xFFC72C48)),
              const SizedBox(height: 20),
              Text(
                _statusMessage ?? 'Authentification requise',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 30),
              if (_needsConfiguration)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800020)),
                  onPressed: _verifyBiometric,
                  child: const Text('J\'ai ajouté mon empreinte (Vérifier)', style: TextStyle(color: Colors.white)),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800020)),
                  onPressed: _verifyBiometric,
                  child: const Text('Réessayer l\'empreinte', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A050A),
            body: Center(child: CircularProgressIndicator(color: Color(0xFFC72C48))),
          );
        }
        if (snapshot.hasData) {
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}