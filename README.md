# Audio App - Secure Audio Streaming

Une application Flutter complète pour le streaming audio sécurisé avec authentification biométrique.

## 🎯 Fonctionnalités principales

### Authentification & Sécurité

- ✅ Authentification biométrique (empreinte digitale)
- ✅ Authentification Firebase (login, register)
- ✅ Récupération de mot de passe
- ✅ Protection biométrique pour les actions sensibles

### Page d'accueil/Statistiques

- ✅ Message de bienvenue avec nom complet en gras
- ✅ Total heures/minutes d'écoute
- ✅ Histogramme: minutes/jour du mois actuel
- ✅ Liste des pistes les plus écoutées
- ✅ Barre de progression de l'objectif mensuel (par défaut 20h, dropdown, sauvegardé localement)

### Lecteur audio

- ✅ Lecture en arrière-plan
- ✅ Playlist dynamique depuis une API externe (quran.yousefheiba.com)
- ✅ Organisation par catégorie → pistes
- ✅ Contrôles: Jouer, Pause, Répéter

### Favoris

- ✅ Ajout aux favoris
- ✅ Sauvegarde en ligne via Firebase
- ✅ Authentification biométrique requise pour supprimer un favori

## 📦 Packages utilisés

- **local_auth**: Authentification biométrique/empreinte digitale
- **firebase_auth**: Authentification Firebase
- **cloud_firestore**: Base de données cloud pour les favoris
- **just_audio**: Lecteur audio avec lecture en arrière-plan
- **fl_chart**: Histogrammes et graphiques
- **shared_preferences**: Stockage local pour les objectifs
- **dio**: Appels API HTTP
- **provider**: Gestion d'état
- **google_fonts**: Polices personnalisées

## 🚀 Installation

### Prérequis

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0

### Configuration Firebase

1. Créez un projet Firebase sur [console.firebase.google.com](https://console.firebase.google.com)
2. Mettez à jour les identifiants dans [lib/firebase_options.dart](lib/firebase_options.dart):
   ```dart
   static const FirebaseOptions android = FirebaseOptions(
     apiKey: 'VOTRE_API_KEY',
     appId: 'VOTRE_APP_ID',
     messagingSenderId: 'VOTRE_SENDER_ID',
     projectId: 'VOTRE_PROJECT_ID',
     databaseURL: 'VOTRE_DATABASE_URL',
     storageBucket: 'VOTRE_STORAGE_BUCKET',
   );
   ```

### Installation des dépendances

```bash
flutter pub get
```

### Lancer l'application

```bash
flutter run
```

## 📁 Structure du projet

```
lib/
├── main.dart                 # Point d'entrée
├── firebase_options.dart     # Configuration Firebase
├── themes/
│   └── app_theme.dart        # Thèmes clair et sombre
├── services/
│   ├── auth_service.dart     # Authentification Firebase
│   ├── biometric_service.dart # Authentification biométrique
│   ├── favorite_service.dart # Gestion des favoris
│   ├── audio_service.dart    # Lecteur audio
│   └── api_service.dart      # Appels API
└── screens/
    ├── splash_screen.dart    # Écran de démarrage
    ├── login_screen.dart     # Connexion
    ├── register_screen.dart  # Inscription
    ├── main_screen.dart      # Navigation principale
    ├── home_screen.dart      # Accueil avec statistiques
    ├── player_screen.dart    # Lecteur audio
    ├── favorites_screen.dart # Favoris
    └── settings_screen.dart  # Paramètres
```

## 🔐 Flux d'authentification

1. **Splash Screen** → Chargement initiale
2. **Auth Check** → Vérification de la session Firebase
3. **Biometric Check** → Authentification biométrique si disponible
4. **Home Screen** → Application principale

## 🎵 Intégration API

L'application utilise l'API Quran gratuite:

```
Base URL: https://quran.yousefheiba.com/api/v3
```

## 🎨 Thème

- **Couleur primaire**: #6366F1 (Indigo)
- **Couleur secondaire**: #EC4899 (Rose)
- **Couleur de succès**: #34D399 (Vert)
- **Police**: Poppins

## 📱 Déploiement

### Android

```bash
flutter build apk
# ou pour AAB (Google Play)
flutter build appbundle
```

### iOS

```bash
flutter build ios
```

## 🤝 Contribution

Les contributions sont les bienvenues! Veuillez:

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est disponible sous la License MIT.

## 🆘 Support

Pour toute question ou problème:

1. Consultez la [documentation Flutter](https://flutter.dev/docs)
2. Consultez la [documentation Firebase](https://firebase.google.com/docs/flutter)
3. Ouvrez une issue sur le projet

---

Construit avec ❤️ en Flutter
