#!/bin/bash

# Audio App - Quick Commands

# ============================================
# 🚀 DÉMARRAGE RAPIDE
# ============================================

# Obtenir les dépendances
get_deps() {
    flutter pub get
    echo "✅ Dépendances installées"
}

# Nettoyer le projet
clean_project() {
    flutter clean
    rm -rf ios/Pods ios/Podfile.lock
    flutter pub get
    echo "✅ Projet nettoyé"
}

# Vérifier l'installation Flutter
check_flutter() {
    flutter doctor -v
}

# ============================================
# 📱 DÉVELOPPEMENT
# ============================================

# Lancer sur Android
run_android() {
    flutter run -d android
}

# Lancer sur iOS
run_ios() {
    flutter run -d ios
}

# Lancer sur Web
run_web() {
    flutter run -d chrome
}

# Lancer en mode profile (performance)
run_profile() {
    flutter run --profile
}

# ============================================
# 🔍 ANALYSE ET FORMAT
# ============================================

# Analyser le code
analyze() {
    flutter analyze
    echo "✅ Analyse terminée"
}

# Formater le code
format() {
    flutter format lib/
    echo "✅ Code formaté"
}

# ============================================
# 🔨 BUILD
# ============================================

# Build APK (Android)
build_apk() {
    flutter build apk --release
    echo "✅ APK généré: build/app/outputs/flutter-apk/app-release.apk"
}

# Build App Bundle (Google Play)
build_bundle() {
    flutter build appbundle --release
    echo "✅ App Bundle généré: build/app/outputs/bundle/release/app-release.aab"
}

# Build iOS
build_ios() {
    flutter build ios --release
    echo "✅ Build iOS terminé"
}

# ============================================
# 🧪 TESTS
# ============================================

# Exécuter les tests
run_tests() {
    flutter test
}

# Test avec couverture
test_coverage() {
    flutter test --coverage
    lcov -r coverage/lcov.info -o coverage/lcov_filtered.info '**/model.dart'
}

# ============================================
# 🔧 CONFIGURATION
# ============================================

# Générer les builders
generate_builders() {
    flutter pub run build_runner build
}

# Générer les locales
generate_locales() {
    flutter gen-l10n
}

# ============================================
# 📝 UTILITAIRES
# ============================================

# Ver logs
show_logs() {
    flutter logs
}

# Obtenir l'info device
device_info() {
    flutter devices
}

# Pub upgrade
pub_upgrade() {
    flutter pub upgrade
}

# ============================================
# 💡 AIDE
# ============================================

show_help() {
    echo "Audio App - Commandes disponibles:"
    echo ""
    echo "🚀 Démarrage:"
    echo "  ./scripts.sh get_deps        - Installer les dépendances"
    echo "  ./scripts.sh clean_project   - Nettoyer le projet"
    echo "  ./scripts.sh check_flutter   - Vérifier l'installation"
    echo ""
    echo "📱 Développement:"
    echo "  ./scripts.sh run_android     - Lancer sur Android"
    echo "  ./scripts.sh run_ios         - Lancer sur iOS"
    echo "  ./scripts.sh run_web         - Lancer sur Web"
    echo ""
    echo "🔍 Analyse:"
    echo "  ./scripts.sh analyze         - Analyser le code"
    echo "  ./scripts.sh format          - Formater le code"
    echo ""
    echo "🔨 Build:"
    echo "  ./scripts.sh build_apk       - Générer APK"
    echo "  ./scripts.sh build_bundle    - Générer App Bundle"
    echo "  ./scripts.sh build_ios       - Générer build iOS"
    echo ""
    echo "🧪 Tests:"
    echo "  ./scripts.sh run_tests       - Exécuter les tests"
    echo "  ./scripts.sh test_coverage   - Tests avec couverture"
    echo ""
}

# ============================================
# EXÉCUTION
# ============================================

if [ $# -eq 0 ]; then
    show_help
else
    $1
fi
