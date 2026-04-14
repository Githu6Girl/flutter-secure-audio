class ValidationHelper {
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$';

  static bool isValidEmail(String email) {
    final regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isStrongPassword(String password) {
    final regex = RegExp(passwordPattern);
    return regex.hasMatch(password);
  }

  static bool isValidName(String name) {
    return name.isNotEmpty && name.length >= 2;
  }

  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email est requis';
    }
    if (!isValidEmail(value)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nom est requis';
    }
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmation du mot de passe est requise';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }
}
