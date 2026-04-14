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

  @override
  void initState() {
    super.initState();
    _verifyBiometric();
  }

  Future<void> _verifyBiometric() async {
    final biometricService = context.read<BiometricService>();
    final isSupported = await biometricService.isBiometricAvailable();
    final hasEnrolled = await biometricService.hasEnrolledBiometrics();

    if (!isSupported) {
      setState(() {
        _isChecking = false;
        _statusMessage = 'Aucun matériel biométrique détecté. Vous pouvez continuer vers l\'authentification Firebase.';
      });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).pushReplacementNamed('/auth');
      return;
    }

    if (!hasEnrolled) {
      setState(() {
        _isChecking = false;
        _statusMessage = 'Aucune empreinte n\'est configurée. Ouvrez les paramètres pour en ajouter une.';
      });
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        await biometricService.openBiometricSettings();
      }
      return;
    }

    final isAuthenticated = await biometricService.authenticate();
    if (!isAuthenticated) {
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _statusMessage = 'Authentification biométrique échouée. Réessayez ou utilisez Firebase.';
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Authentification échouée'),
          content: const Text('Impossible de valider l\'empreinte. Réessayez ou passez à l\'authentification Firebase.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _verifyBiometric();
              },
              child: const Text('Réessayer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed('/auth');
              },
              child: const Text('Connexion Firebase'),
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
      body: Center(
        child: _isChecking
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Vérification biométrique en cours...'),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _statusMessage ?? 'Préparation de l\'authentification...',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/auth');
                        }
                      },
                      child: const Text('Continuer vers Firebase'),
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
