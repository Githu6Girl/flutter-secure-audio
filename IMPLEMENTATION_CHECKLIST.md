# ✅ Checklist d'implémentation et de déploiement

## 📋 Phase 1: Configuration initiale (À faire d'abord)

### Firebase Setup

- [ ] Créer un projet Firebase (https://console.firebase.google.com)
- [ ] Activer Authentication (Email/Password)
- [ ] Créer une base de données Firestore (mode test)
- [ ] Récupérer `google-services.json` (Android)
- [ ] Récupérer `GoogleService-Info.plist` (iOS)
- [ ] Mettre à jour `lib/firebase_options.dart` avec les credentials
- [ ] Tester les connections Firebase avec un test simple

### Dépendances Flutter

- [ ] Exécuter `flutter pub get`
- [ ] Vérifier qu'il n'y a pas d'erreurs
- [ ] Exécuter `flutter analyze` pour vérifier le linting

### Configuration de plateforme

#### Android

- [ ] Placer `google-services.json` dans `android/app/`
- [ ] Vérifier `android/app/build.gradle` (compileSdk 33+)
- [ ] Vérifier les permissions dans `AndroidManifest.xml`
- [ ] Tester avec `flutter run -d android`

#### iOS

- [ ] Ajouter `GoogleService-Info.plist` via Xcode
- [ ] Configurer `ios/Runner/Info.plist` (biométrie)
- [ ] Exécuter `pod install` dans le dossier `ios/`
- [ ] Tester avec `flutter run -d ios`

## 🔧 Phase 2: Configuration des fonctionnalités

### Authentification

- [ ] Vérifier que la connexion Firebase fonctionne
- [ ] Tester l'enregistrement d'un nouvel utilisateur
- [ ] Vérifier la validation d'âge (≥13 ans)
- [ ] Tester la connexion/déconnexion
- [ ] Vérifier que les données sont sauvegardées dans Firestore

### Authentification biométrique

- [ ] Tester sur un appareil avec biométrie
- [ ] Vérifier les permissions (iOS Info.plist, Android Manifest)
- [ ] Tester avec fingerprint (Android)
- [ ] Tester avec Face ID (iOS)
- [ ] Vérifier le fallback quand pas de biométrie

### Lecteur audio

- [ ] Tester la connexion à l'API Quran
- [ ] Vérifier que les catégories s'affichent
- [ ] Tester la lecture d'une piste
- [ ] Vérifier les contrôles (play, pause, skip)
- [ ] Tester le mode répétition
- [ ] Tester la barre de progression

### Favoris

- [ ] Tester l'ajout aux favoris
- [ ] Vérifier la synchronisation Firestore
- [ ] Tester la suppression avec biométrie
- [ ] Vérifier l'affichage des favoris

### Statistiques

- [ ] Tester l'affichage des stats
- [ ] Tester la modification de l'objectif mensuel
- [ ] Vérifier la persistance locale (SharedPreferences)
- [ ] Tester l'histogramme avec données

## 🎨 Phase 3: Vérification UI/UX

### Responsivité

- [ ] Tester en mode portrait
- [ ] Tester en mode landscape
- [ ] Tester sur différentes tailles d'écran
- [ ] Vérifier les layouts sur tablette

### Thèmes

- [ ] Tester le thème clair
- [ ] Tester le thème sombre
- [ ] Vérifier la cohérence des couleurs
- [ ] Tester le switch thème système

### Navigation

- [ ] Tester la navigation bottom nav
- [ ] Tester le back button
- [ ] Vérifier la persistance du tab sélectionné
- [ ] Tester les routes nommées

### Gestion des erreurs

- [ ] Tester sans connexion Internet
- [ ] Tester avec Firebase hors ligne
- [ ] Vérifier les messages d'erreur
- [ ] Tester le retry des API

## 📱 Phase 4: Tests de performance

### Généralités

- [ ] Vérifier l'utilisation mémoire (DevTools)
- [ ] Vérifier l'utilisation CPU
- [ ] Tester avec une connexion lente (throttle à 4G)
- [ ] Tester le démarrage app (< 3s)

### Audio

- [ ] Tester la lecture en arrière-plan
- [ ] Vérifier qu'il n'y a pas de crash pendant la lecture
- [ ] Tester le switch de piste rapide
- [ ] Vérifier la batterie (pas de drain)

### Firestore

- [ ] Vérifier les lectures/écritures (monitoring console)
- [ ] Tester les requêtes complexes (pagination si besoin)
- [ ] Vérifier la latence de synchronisation

## 🔐 Phase 5: Vérification de sécurité

### Authentification

- [ ] Vérifier le stockage des tokens
- [ ] Tester la réinitialisation de mot de passe
- [ ] Vérifier la validation des entrées
- [ ] Tester la force du mot de passe

### Données

- [ ] Vérifier les règles Firestore (pas d'accès non autorisé)
- [ ] Tester l'isolation des données utilisateur
- [ ] Vérifier qu'on ne sauvegarde pas de données sensibles localement
- [ ] Tester la suppression des données

### HTTPS

- [ ] Vérifier que toutes les API calls utilisent HTTPS
- [ ] Vérifier les certificats SSL

## 🚀 Phase 6: Préparation au déploiement

### Version et Build

- [ ] Incrémenter la version dans `pubspec.yaml`
- [ ] Vérifier le build number
- [ ] Générer les icônes app (si pas déjà fait)
- [ ] Générer les screenshots

### Android

- [ ] Générer la clé de signature (keystore)
- [ ] Vérifier le applicationId
- [ ] Vérifier le versionCode et versionName
- [ ] Tester le build release: `flutter build apk --release`
- [ ] Générer l'App Bundle: `flutter build appbundle --release`
- [ ] Signer l'APK/Bundle

### iOS

- [ ] Vérifier le Bundle Identifier
- [ ] Vérifier la version et build number
- [ ] Configurer les certificates/provisioning profiles
- [ ] Tester le build release: `flutter build ios --release`
- [ ] Archiver via Xcode
- [ ] Signer et uploader via Testflight

## 📊 Phase 7: Lancement

### Google Play Store

- [ ] Créer la fiche app
- [ ] Ajouter les screenshots, descriptions
- [ ] Uploader l'App Bundle
- [ ] Remplir les informations de contenu
- [ ] Soumettre pour review
- [ ] Monitorer la soumission (cela peut prendre 24-48h)

### App Store

- [ ] Créer la fiche app
- [ ] Ajouter les screenshots, descriptions
- [ ] Uploader via Testflight
- [ ] Inviter les testeurs
- [ ] Soumettre pour review
- [ ] Monitorer la soumission (cela peut prendre 24-48h)

## 📈 Phase 8: Post-lancement

### Monitoring

- [ ] Configurer Firebase Analytics
- [ ] Configurer Firebase Crashlytics
- [ ] Monitorer les erreurs
- [ ] Vérifier les métriques d'utilisation

### Support

- [ ] Configurer un système de feedback
- [ ] Monitorer les reviews utilisateurs
- [ ] Préparer les hot fixes si besoin
- [ ] Planifier les mises à jour futures

## 🐛 Dépannage rapide

**L'app ne démarre pas**

- [ ] Vérifier que Firebase est configuré
- [ ] Vérifier les logs: `flutter logs`
- [ ] Exécuter `flutter clean && flutter pub get`

**Erreur de compilation Android**

- [ ] Vérifier le targetSdkVersion
- [ ] Exécuter: `flutter clean && flutter pub get`
- [ ] Vérifier google-services.json

**Erreur de compilation iOS**

- [ ] Exécuter: `cd ios && pod install --repo-update && cd ..`
- [ ] Nettoyer Xcode: `flutter clean`
- [ ] Vérifier GoogleService-Info.plist

**Biométrie ne fonctionne pas**

- [ ] Vérifier les permissions
- [ ] Vérifier que l'appareil a la biométrie
- [ ] Vérifier qu'une empreinte/face est enregistrée

**API ne répond pas**

- [ ] Vérifier la connexion Internet
- [ ] Vérifier l'URL de l'API
- [ ] Vérifier le format de la réponse
- [ ] Vous connecter en VPN si géo-bloqué

## ✨ Prochaines améliorations

- [ ] Ajouter des tests unitaires
- [ ] Ajouter des tests d'intégration
- [ ] Ajouter la recherche de pistes
- [ ] Ajouter les playlists personnalisées
- [ ] Ajouter le partage de favoris
- [ ] Ajouter les notifications
- [ ] Ajouter la recommandation de pistes
- [ ] Ajouter le multi-langue (i18n)
- [ ] Ajouter l'offline mode
- [ ] Ajouter les widgets de partage

---

**Bon développement! 🚀**

_Checkliste complétée: ?/?_
