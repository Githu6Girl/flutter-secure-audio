class AppConstants {
  // App Info
  static const String appName = 'Audio App';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // API Configuration
  static const String apiBaseUrl = 'https://quran.yousefheiba.com/api/v3';
  static const int apiTimeoutMs = 30000; // 30 seconds

  // Firebase Configuration
  static const String firebaseProjectId = 'your-firebase-project-id';

  // Feature Flags
  static const bool enableBiometricAuth = true;
  static const bool enableOfflineMode = false;
  static const bool enableAnalytics = true;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cornerRadius = 12.0;
  static const double cardElevation = 0.0;

  // Duration Constants
  static const Duration splashScreenDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // Validation Constants
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int minAgeRequired = 13;

  // Default Values
  static const int defaultMonthlyGoalHours = 20;
  static const int maxMonthlyGoalHours = 100;
  static const int minMonthlyGoalHours = 1;

  // Cache/Storage Keys
  static const String keyMonthlyGoalHours = 'monthlyGoalHours';
  static const String keyTotalListeningMinutes = 'totalListeningMinutes';
  static const String keyLastSyncTime = 'lastSyncTime';
  static const String keyUserPreferences = 'userPreferences';
  static const String keyBiometricEnabled = 'biometricEnabled';

  // Error Messages
  static const String errorNetworkFailed = 'Erreur de connexion réseau';
  static const String errorServerError = 'Erreur serveur. Veuillez réessayer.';
  static const String errorUnknown = 'Une erreur inconnue s\'est produite';
  static const String errorInvalidCredentials = 'Email ou mot de passe invalide';
  static const String errorUserNotFound = 'Utilisateur non trouvé';
  static const String errorAccountExists = 'Un compte avec cet email existe déjà';

  // Success Messages
  static const String successLoginComplete = 'Connexion réussie';
  static const String successRegistrationComplete = 'Inscription réussie';
  static const String successLogout = 'Déconnexion réussie';
  static const String successFavoritesAdded = 'Ajouté aux favoris';
  static const String successFavoritesRemoved = 'Supprimé des favoris';

  // Biometric Messages
  static const String biometricReason = 'Veuillez vous authentifier pour accéder à l\'application';
  static const String biometricReasonDelete = 'Authentifiez-vous pour supprimer ce favori';

  // Date Formats
  static const String dateFormatPattern = 'dd/MM/yyyy';
  static const String timeFormatPattern = 'HH:mm';
  static const String dateTimeFormatPattern = 'dd/MM/yyyy HH:mm';

  // URLs
  static const String privacyPolicyUrl =
      'https://example.com/privacy-policy';
  static const String termsOfServiceUrl =
      'https://example.com/terms-of-service';
  static const String supportUrl = 'https://example.com/support';
}

class ApiEndpoints {
  static const String chapters = '/chapters';
  static const String translations = '/chapters/{id}/translations/{langId}';
  static const String search = '/search';

  static String getChapterUrl(int chapterId, int langId) {
    return '/chapters/$chapterId/translations/$langId';
  }
}
