# 🎧 Flutter Secure Audio App

A complete Flutter application for **secure audio streaming** with biometric authentication and Firebase integration.

---

## 🚀 Features

### 🔐 Authentication & Security

* Biometric authentication (fingerprint)
* Firebase Authentication (login & register)
* Password recovery
* Biometric protection for sensitive actions

### 📊 Dashboard & Analytics

* Personalized welcome message (bold full name)
* Total listening time (hours/minutes)
* Monthly listening histogram (minutes/day)
* Most played tracks
* Monthly goal progress bar (default 20h, customizable & locally saved)

### 🎵 Audio Player

* Background playback
* Dynamic playlist from external API
  → https://quran.yousefheiba.com
* Category → tracks organization
* Controls: Play, Pause, Repeat

### ❤️ Favorites

* Add/remove favorites
* Cloud sync with Firebase
* Biometric authentication required for deletion

---

## 🛠️ Tech Stack

* **Flutter / Dart**
* **Firebase Auth**
* **Cloud Firestore**
* **Just Audio**
* **FL Chart**
* **Provider (State Management)**
* **Dio (HTTP Requests)**
* **Shared Preferences**
* **Local Auth (Biometrics)**
* **Google Fonts**

---

## ⚙️ Installation

### Prerequisites

* Flutter SDK >= 3.0.0
* Dart SDK >= 3.0.0

### Setup

```bash
flutter pub get
flutter run
```

---

## 🔥 Firebase Configuration

1. Create a project on https://console.firebase.google.com
2. Update credentials in:

```
lib/firebase_options.dart
```

---

## 📁 Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── themes/
│   └── app_theme.dart
├── services/
│   ├── auth_service.dart
│   ├── biometric_service.dart
│   ├── favorite_service.dart
│   ├── audio_service.dart
│   └── api_service.dart
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── register_screen.dart
    ├── main_screen.dart
    ├── home_screen.dart
    ├── player_screen.dart
    ├── favorites_screen.dart
    └── settings_screen.dart
```

---

## 🔐 Authentication Flow

1. Splash Screen
2. Firebase Session Check
3. Biometric Authentication
4. Home Screen

---

## 🎨 UI Theme

* Primary: `#6366F1` (Indigo)
* Secondary: `#EC4899` (Pink)
* Success: `#34D399` (Green)
* Font: **Poppins**

---

## 📱 Build

### Android

```bash
flutter build apk
flutter build appbundle
```

### iOS

```bash
flutter build ios
```

---

## 🤝 Contributing

Feel free to fork and improve the project!

```bash
git checkout -b feature/your-feature
git commit -m "Add feature"
git push origin feature/your-feature
```

---

## 📄 License

MIT License

---

## ⭐ Support

If you like this project, consider giving it a star ⭐

---

Built with ❤️ using Flutter
