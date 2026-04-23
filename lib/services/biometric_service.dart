import 'package:flutter/services.dart'; // Ajouté pour utiliser les sons système (SystemSound)
import 'package:app_settings/app_settings.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuthentication.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasEnrolledBiometrics() async {
    try {
      final availableBiometrics =
      await _localAuthentication.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _localAuthentication.authenticate(
        localizedReason: 'Veuillez vous authentifier pour accéder à l\'application',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticateForAction(String reason) async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<bool> openBiometricSettings() async {
    try {
      // NOUVELLE COMMANDE POUR APP_SETTINGS v5+
      await AppSettings.openAppSettings(type: AppSettingsType.security);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> playSuccessSound() async {
    try {
      // UTILISATION DU BIP NATIF DE FLUTTER (Remplaçant flutter_beep)
      SystemSound.play(SystemSoundType.click);
    } catch (_) {
      // Fallback silencieux
    }
  }
}