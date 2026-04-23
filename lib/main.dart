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
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<BiometricService>(create: (_) => BiometricService()),
        ChangeNotifierProvider<FavoriteService>(
          create: (_) => FavoriteService(),
        ),
      ],
      child: MaterialApp(
        title: 'Audio App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const BiometricGateScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
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
      // Cas rare (vieux tel sans capteur). On le laisse passer pour ne pas bloquer l'app.
      if (mounted) Navigator.of(context).pushReplacementNamed('/auth');
      return;
    }

    if (!hasEnrolled) {
      // RESPECT DU PDF : Aucune empreinte, on bloque et on force à aller dans les paramètres
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
      // RESPECT DU PDF : Échec ou Annulation -> On bloque tout ! Pas de bouton "Passer".
      if (!mounted) return;
      setState(() {
        _isChecking = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false, // Empêche de fermer la popup en cliquant à côté
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Accès refusé', style: TextStyle(color: Colors.white)),
          content: const Text('L\'empreinte digitale est obligatoire pour accéder à l\'application.', style: TextStyle(color: Colors.white70)),
          actions:[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _verifyBiometric(); // Oblige à recommencer
              },
              child: const Text('Réessayer', style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    // SUCCÈS ! (On joue le son et on passe à Firebase)
    await biometricService.playSuccessSound();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Center(
        child: _isChecking
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: const[
            CircularProgressIndicator(color: Color(0xFF6366F1)),
            SizedBox(height: 20),
            Text('Vérification de sécurité...', style: TextStyle(color: Colors.white70)),
          ],
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              const Icon(Icons.security, size: 60, color: Color(0xFFF87171)),
              const SizedBox(height: 20),
              Text(
                _statusMessage ?? 'Authentification requise',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 30),
              if (_needsConfiguration)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                  onPressed: _verifyBiometric,
                  child: const Text('J\'ai ajouté mon empreinte (Vérifier)', style: TextStyle(color: Colors.white)),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
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
            body: Center(child: CircularProgressIndicator()),
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
