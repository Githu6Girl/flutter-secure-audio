import 'package:app_settings/app_settings.dart';
import 'package:flutter_beep/flutter_beep.dart';
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
      AppSettings.openSecuritySettings();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> playSuccessSound() async {
    try {
      FlutterBeep.beep();
    } catch (_) {
      // Fallback silencieux si le son ne peut pas être joué.
    }
  }
}
