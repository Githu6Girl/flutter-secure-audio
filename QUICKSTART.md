# Audio App - Guide de démarrage rapide

## ✅ Qu'a été créé

### 📁 Structure du projet

- ✅ `pubspec.yaml` - Dépendances complètes
- ✅ `.gitignore` - Configuration Git
- ✅ `analysis_options.yaml` - Règles de linting
- ✅ `README.md` - Documentation générale
- ✅ `SETUP.md` - Guide d'installation détaillé

### 🔧 Services

- ✅ `lib/services/auth_service.dart` - Authentification Firebase
- ✅ `lib/services/biometric_service.dart` - Reconnaissance biométrique
- ✅ `lib/services/favorite_service.dart` - Gestion des favoris
- ✅ `lib/services/audio_service.dart` - Lecteur audio
- ✅ `lib/services/api_service.dart` - Appels API externes

### 🎨 Thèmes et UI

- ✅ `lib/themes/app_theme.dart` - Thèmes clair/sombre

### 📱 Écrans

- ✅ `lib/screens/splash_screen.dart` - Écran de démarrage
- ✅ `lib/screens/login_screen.dart` - Connexion
- ✅ `lib/screens/register_screen.dart` - Inscription
- ✅ `lib/screens/main_screen.dart` - Navigation principale
- ✅ `lib/screens/home_screen.dart` - Accueil avec statistiques
- ✅ `lib/screens/player_screen.dart` - Lecteur audio
- ✅ `lib/screens/favorites_screen.dart` - Favoris protégés
- ✅ `lib/screens/settings_screen.dart` - Paramètres utilisateur

### 📂 Répertoires d'assets

- ✅ `assets/images/` - Images de l'app
- ✅ `assets/sounds/` - Sons et audio
- ✅ `assets/fonts/` - Polices personnalisées

## 🎯 Prochaines étapes

### 1. Configuration Firebase (PRIORITÉ HAUTE)

```bash
# D'abord, consultez SETUP.md pour la configuration complète
```

**Vous devez:**

1. Créer un projet Firebase
2. Récupérer `google-services.json` (Android)
3. Récupérer `GoogleService-Info.plist` (iOS)
4. Mettre à jour `lib/firebase_options.dart`

### 2. Installation des dépendances

```bash
flutter pub get
```

### 3. Générer les fichiers localisés (optionnel)

```bash
flutter gen-l10n
```

### 4. Configuration spécifique à la plateforme

#### Android:

```bash
# Placez google-services.json dans android/app/
cd android
./gradlew clean
cd ..
```

#### iOS:

```bash
cd ios
pod install --repo-update
cd ..
```

### 5. Tester l'application

```bash
# Sur appareil Android
flutter run -d android

# Sur simulateur iOS
flutter run -d ios

# Sur navigateur web
flutter run -d chrome
```

## 🔑 Éléments clés à personnaliser

1. **Firebase Credentials** (`lib/firebase_options.dart`)
   - API Key
   - App ID
   - Project ID
   - Auth Domain
   - Database URL
   - Storage Bucket

2. **App Name/ID**
   - Android: `android/app/build.gradle` → `applicationId`
   - iOS: `ios/Runner.xcodeproj` → General → Bundle Identifier

3. **Assets**
   - Ajoutez vos images dans `assets/images/`
   - Ajoutez vos sons dans `assets/sounds/`
   - Ajoutez vos polices dans `assets/fonts/`

## 📊 Flux d'authentification

```
AppStart
  ↓
SplashScreen (2 secondes)
  ↓
AuthCheck (Firebase)
  ├─ ✗ Non authentifié → LoginScreen
  └─ ✓ Authentifié → BiometricCheck
       ├─ ✗ Pas de biométrie → MainScreen
       └─ ✓ Authentification biométrique
            ├─ ✓ Réussi → MainScreen
            └─ ✗ Échoué → Retry/Logout
```

## 🔐 Fonctionnalités de sécurité

- ✅ Authentification Firebase (Email/Password)
- ✅ Biométrie obligatoire au lancement
- ✅ Biométrie requise pour supprimer des favoris
- ✅ Stockage sécurisé des données
- ✅ HTTPS pour toutes les API
- ✅ Validation d'âge (≥13 ans)

## 🎵 Intégration API

L'application utilise l'API Quran gratuite:

```
GET https://quran.yousefheiba.com/api/v3/chapters
GET https://quran.yousefheiba.com/api/v3/chapters/{id}/translations/{lang_id}
```

## 📦 Dépendances principales

| Package            | Version | Utilité                   |
| ------------------ | ------- | ------------------------- |
| flutter_auth       | 4.10.0  | Authentification Firebase |
| cloud_firestore    | 4.13.0  | Base de données cloud     |
| local_auth         | 2.1.0   | Biométrie                 |
| just_audio         | 0.9.34  | Lecteur audio             |
| fl_chart           | 0.65.0  | Graphiques                |
| shared_preferences | 2.2.0   | Stockage local            |
| dio                | 5.3.0   | Appels HTTP               |
| provider           | 6.0.0   | Gestion d'état            |

## 🧪 Liste de contrôle avant le déploiement

- [ ] Firebase configuré et testé
- [ ] Permissions Android/iOS vérifiées
- [ ] Biométrie testée sur appareil réel
- [ ] API Quran testée
- [ ] Stockage Firestore testé
- [ ] Stockage local testé
- [ ] Thème sombre/clair testé
- [ ] Rotation de l'écran testée
- [ ] Performance vérifiée
- [ ] Pas d'erreurs de build
- [ ] Version de l'app incrémentée
- [ ] Icône de l'app définie

## 🆘 Commandes utiles

```bash
# Nettoyer le build
flutter clean

# Obtenir les dépendances
flutter pub get

# Mettre à jour les dépendances
flutter pub upgrade

# Analyser le code
flutter analyze

# Formater le code
flutter format lib/

# Tester la structure
flutter pub run build_runner build

# Vérifier doctor
flutter doctor -v
```

## 📝 Notes importantes

1. **Firebase Rules**: Par défaut, Firestore est en mode "test". Avant de déployer en production, mettez à jour les règles de sécurité.

2. **API Limits**: L'API Quran est gratuite. Vérifiez les limites de débit.

3. **Permissions**:
   - Android: Biométrie, Internet
   - iOS: Face ID, Internet

4. **Support**: Le code supporte iOS 11.0+, Android API 21+

## 🚀 Pour déployer

**Voir SETUP.md pour les instructions complètes de déploiement Google Play Store et App Store.**

---

**Questions?** Consultez la [documentation Flutter](https://flutter.dev/docs) ou [Firebase](https://firebase.google.com/docs/flutter)
