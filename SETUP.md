# Installation et Configuration de l'Audio App

## 📋 Pré-requis

- **Flutter SDK**: Version 3.0.0 ou supérieure
- **Dart SDK**: Version 3.0.0 ou supérieure
- **Xcode** (pour iOS): Version 14.0 ou supérieure
- **Android Studio**: Version 2022.1 ou supérieure
- **CocoaPods** (pour iOS): Version 1.12.0 ou supérieure

## ⚙️ Configuration Flutter

### 1. Vérifier votre installation Flutter

```bash
flutter doctor
```

Assurez-vous que tous les éléments essentiels sont cochés (verts) ✓

### 2. Mettre à jour Flutter

```bash
flutter upgrade
```

### 3. Activer les plateforme web (optionnel)

```bash
flutter config --enable-web
```

## 🔐 Configuration Firebase

### 1. Créer un projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Cliquez sur "Ajouter un projet"
3. Remplissez les détails du projet
4. Activez les services:
   - **Authentication**: Email/Password
   - **Cloud Firestore**: Start in test mode
   - **Realtime Database** (optionnel)

### 2. Récupérer les clés de configuration

#### Pour Android:

1. Allez dans Project Settings → Your apps → Android
2. Télécharger `google-services.json`
3. Placez-le dans `android/app/`

#### Pour iOS:

1. Allez dans Project Settings → Your apps → iOS
2. Télécharger `GoogleService-Info.plist`
3. Utilisez Xcode pour l'ajouter (drag & drop dans Xcode)

#### Pour Web:

1. Allez dans Project Settings → Your apps → Web
2. Copiez la configuration Firebase
3. Mettez-la à jour dans `lib/firebase_options.dart`

### 3. Activer l'authentification par email

1. Dans Firebase Console → Authentication → Sign-In Method
2. Activez "Email/Password"
3. Sauvegardez

### 4. Configurer Firestore

1. Dans Firebase Console → Firestore Database
2. Cliquez sur "Créer une base de données"
3. Choisir "Démarrer en mode test"
4. Sélectionnez votre région

## 📱 Configuration spécifique par plateforme

### Android

#### 1. Configurer build.gradle

Vérifiez que `android/app/build.gradle` contient:

```gradle
android {
    compileSdkVersion 33

    defaultConfig {
        applicationId "com.example.audio_app"
        minSdkVersion 21
        targetSdkVersion 33
    }
}

dependencies {
    implementation 'com.google.firebase:firebase-analytics'
}

apply plugin: 'com.google.gms.google-services'
```

#### 2. Configurer AndroidManifest.xml

Assurez-vous que `android/app/src/main/AndroidManifest.xml` contient:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

#### 3. Activer Multidex

Si vous avez des erreurs multidex, ajoutez dans `android/app/build.gradle`:

```gradle
defaultConfig {
    multiDexEnabled true
}
```

### iOS

#### 1. Configuration Info.plist

Modifiez `ios/Runner/Info.plist` et ajoutez:

```xml
<key>NSFaceIDUsageDescription</key>
<string>L'application a besoin d'accès à Face ID pour l'authentification biométrique</string>
<key>NSBiometricsUsageDescription</key>
<string>L'application a besoin d'accès à la biométrie pour l'authentification</string>
```

#### 2. Activer les capacités

1. Ouvrez `ios/Runner.xcworkspace` dans Xcode
2. Sélectionnez "Runner" dans le navigateur
3. Allez dans "Signing & Capabilities"
4. Cliquez sur "+ Capability"
5. Ajoutez "Keychain Sharing"

#### 3. Installer les pods

```bash
cd ios
pod install
pod install --repo-update
cd ..
```

#### 4. Configurer le déploiement minimum

Dans Xcode:

1. Sélectionnez "Runner"
2. Allez dans "General"
3. Définissez "iOS Deployment Target" sur 11.0 ou plus

### Web (optionnel)

Les fonctionnalités biométriques ne sont pas disponibles sur le web. Les autres fonctionnalités fonctionneront normalement.

## 🚀 Lancer l'application

### Mode développement

```bash
# Pour Android
flutter run -d android

# Pour iOS
flutter run -d ios

# Pour web
flutter run -d chrome
```

### Mode release

```bash
# Pour Android
flutter build apk --release

# Pour iOS
flutter build ios --release

# Pour build bundle (Google Play)
flutter build appbundle --release
```

## 🔧 Dépannage

### Erreur: "Unable to locate Android SDK"

```bash
flutter config --android-sdk /path/to/android/sdk
```

### Erreur: "Podfile.lock requires CocoaPods version..."

```bash
cd ios
pod repo update
pod install
cd ..
```

### Erreur: "Cannot find flutter binary"

Assurez-vous que `flutter/bin` est dans votre PATH:

```bash
export PATH="$PATH:/path/to/flutter/bin"
```

### Erreur Firebase: "FirebaseOptions not set"

Vérifiez que vous avez mis à jour `lib/firebase_options.dart` avec vos clés Firebase.

### Erreur biométrique sur Android/iOS

Assurez-vous que:

1. Les permissions sont déclarées dans le manifeste
2. L'appareil support la biométrie
3. Au moins une empreinte digitale ou Face ID est enregistrée

## 📦 Structure des fichiers attendue

```
audio_app/
├── android/
│   ├── app/
│   │   ├── google-services.json
│   │   └── build.gradle
│   ├── build.gradle
│   └── settings.gradle
├── ios/
│   ├── Runner.xcworkspace/
│   ├── Runner/
│   │   └── Info.plist
│   └── Podfile
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── themes/
│   ├── services/
│   └── screens/
├── assets/
│   ├── images/
│   ├── sounds/
│   └── fonts/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

## 🧪 Tests

Avant de déployer, testez les fonctionnalités principales:

- [ ] Push d'authentification biométrique
- [ ] Enregistrement et connexion
- [ ] Lecture audio
- [ ] Ajout/suppression de favoris
- [ ] Synchronisation Firestore
- [ ] Sauvegarde locale des préférences

## 📝 Variables d'environnement (optionnel)

Créez un fichier `.env` à la racine du projet:

```
FIREBASE_API_KEY=your_api_key
FIREBASE_APP_ID=your_app_id
FIREBASE_PROJECT_ID=your_project_id
API_BASE_URL=https://quran.yousefheiba.com/api/v3
```

## 🚢 Déploiement

### Google Play Store (Android)

```bash
flutter build appbundle --release
# Puis téléchargez dans Google Play Console
```

### App Store (iOS)

```bash
flutter build ios --release
# Puis utilisez Xcode ou Application Loader
```

## 📚 Ressources utiles

- [Documentation Flutter](https://flutter.dev/docs)
- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter)
- [Local Auth Documentation](https://pub.dev/packages/local_auth)
- [Just Audio Documentation](https://pub.dev/packages/just_audio)

## 🆘 Support

Pour plus d'aide:

1. Consultez la [documentation officielle](https://flutter.dev)
2. Vérifiez les [issues GitHub](project-github-link)
3. Demandez de l'aide sur [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
