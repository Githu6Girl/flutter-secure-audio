# 🌊 Mawja - Audio Experience

A stunning, highly secure audio streaming application built with Flutter. Features a modern **Burgundy Glassmorphism UI**, strict biometric authentication, and seamless Firebase integration.

---

## 🚀 Features

### 🔐 Authentication & Security
- **Biometric Gate:** Mandatory fingerprint authentication at launch (forces OS settings configuration if none is enrolled).
- **Firebase Auth:** Login, Register (with strict age validation > 13 years old), and Password recovery.
- **Sensitive Actions:** Biometric re-authentication required to delete tracks from Favorites.

### ✨ Premium UI/UX — Glassmorphism
- **Frosted Glass Design:** Translucent cards, deep Burgundy/Ruby Red gradients, and glowing borders.
- **Dynamic UX:** Time-based smart greeting (*Bonjour ☀️ / Bonsoir 🌙*).
- **Custom App Icon:** Custom vector wave logo for Android/iOS launchers.

### 📊 Dashboard & Analytics
- Personalized welcome message with the user's full name.
- Total listening time tracking (hours & minutes).
- Monthly listening histogram chart (minutes per day).
- Interactive Monthly Goal progress bar (10h / 20h / 30h / 50h, saved locally).

### 🎵 Smart Audio Player
- **Dynamic Real-Time Search:** Instantly filter tracks and artists.
- **Sleep Timer 🌙:** Auto-pause after 15, 30, or 60 minutes.
- **Share Button 📤:** Native share menu to send track info to friends.
- **API Integration:** Fetches categories and tracks dynamically (MP3Quran / iTunes) with offline fallback.
- **Playback Controls:** Background playback, seek, repeat, play, pause.

### ❤️ Cloud Favorites
- Add/remove tracks to personal favorites.
- Real-time sync with Firebase Firestore.
- Secure deletion protected by biometric prompt.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter / Dart |
| Backend | Firebase Auth & Cloud Firestore |
| Audio Engine | `just_audio` & Audio Session |
| Analytics UI | FL Chart |
| State Management | Provider |
| Networking | Dio |
| Local Storage | Shared Preferences |
| Security | Local Auth (Biometrics) |
| Native Utils | `share_plus` |

---

## ⚙️ Installation & Setup

### Prerequisites
- Flutter SDK `>= 3.0.0`
- Dart SDK `>= 3.0.0`
- Android: `minSdkVersion 23` minimum (required for biometric hardware)

### Steps

```bash
# Clone the repository
git clone https://github.com/Githu6Girl/flutter-secure-audio.git

# Install dependencies
flutter pub get

# Generate app launcher icons
dart run flutter_launcher_icons

# Run the app
flutter run
```

### 🔥 Firebase Configuration

1. Create a project on [Firebase Console](https://console.firebase.google.com).
2. Place `google-services.json` in `android/app/`.
3. Place `GoogleService-Info.plist` in `ios/Runner/`.
4. Ensure the bundle ID matches: `com.meriem.audio_app`.
## 📁 Project Structure
```
lib/
├── main.dart                   # Entry point & Biometric Gate
├── firebase_options.dart       # Firebase configuration
├── services/
│   ├── api_service.dart        # External APIs & search
│   ├── audio_service.dart      # JustAudio playback logic
│   ├── auth_service.dart       # Firebase Auth
│   ├── biometric_service.dart  # Fingerprint / Face ID
│   └── favorite_service.dart   # Firestore sync
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_screen.dart        # Glass Bottom Nav Bar
│   ├── home_screen.dart        # Analytics Dashboard
│   ├── player_screen.dart      # Audio Player & Sleep Timer
│   ├── favorites_screen.dart
│   └── settings_screen.dart
└── widgets/
├── app_background.dart     # Burgundy Gradient Background
├── glass_card.dart         # Frosted Glass Container
└── glass_components.dart   # Glass TextFields & Buttons
```
---

## 🎨 UI Theme

| Role | Color | Hex |
|---|---|---|
| Deep Background | Dark Burgundy | `#1A050A` |
| Primary | Burgundy | `#800020` |
| Accent / Glow | Ruby Red | `#C72C48` |
| Danger | Soft Red | `#F87171` |

---

## 📱 Build

### Android
```bash
flutter build apk
```
> Ensure `MainActivity.kt` extends `FlutterFragmentActivity` for biometrics.

### iOS
```bash
cd ios && pod install && cd ..
flutter build ios
```
> Ensure `NSFaceIDUsageDescription` is set in `Info.plist`.

---

## 🤝 Contributing

Developed as a university academic project. Feel free to fork, explore the code, and improve it!

---

*Built with ❤️ using Flutter & Glassmorphism.*

---

## 📁 Project Structure
