import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get statusBarHeight => MediaQuery.of(this).padding.top;
  double get bottomInset => MediaQuery.of(this).viewInsets.bottom;
  
  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  
  void showSnackBar(String message, {Duration duration = const Duration(seconds: 4)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }
  
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }
  
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  
  void pushReplacementNamed(String name) =>
      Navigator.of(this).pushReplacementNamed(name);
}

extension StringExtensions on String {
  bool get isEmpty => isEmpty;
  bool get isNotEmpty => isNotEmpty;
  
  String get capitalize => isEmpty ? "" : "${this[0].toUpperCase()}${substring(1)}";
  
  String get capitalizeEachWord {
    if (isEmpty) return "";
    return split(" ").map((word) => word.capitalize).join(" ");
  }
  
  bool get isEmailValid {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }
  
  bool get isPhoneValid {
    final phoneRegex = RegExp(r'^[0-9]{10,}$');
    return phoneRegex.hasMatch(removeWhitespace);
  }
  
  String get removeWhitespace => replaceAll(RegExp(r'\s'), '');
  
  String get removeSpecialCharacters =>
      replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
}

extension DurationExtensions on Duration {
  String get formatTime {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  String get formatShort {
    final minutes = inMinutes;
    final seconds = inSeconds.remainder(60);
    
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

extension DateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
  
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }
  
  String get formattedDate {
    if (isToday) return 'Aujourd\'hui';
    if (isYesterday) return 'Hier';
    if (isTomorrow) return 'Demain';
    
    return '$day/$month/$year';
  }
}

extension NumExtensions on num {
  String get formattedSize {
    if (this < 1024) return '$this B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(2)} KB';
    if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
  
  String get formattedCompact {
    if (this < 1000) return toString();
    if (this < 1000000) return '${(this / 1000).toStringAsFixed(1)}K';
    return '${(this / 1000000).toStringAsFixed(1)}M';
  }
}

extension ListExtensions<T> on List<T> {
  List<T> get reversed => [...this]..sort((a, b) => -1);
  
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
  
  Iterable<T> distinct() {
    final set = <T>{};
    return where((element) => set.add(element));
  }
  
  List<T> paginate(int pageNumber, int pageSize) {
    final startIndex = (pageNumber - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    
    if (startIndex >= length) return [];
    return sublist(startIndex, endIndex > length ? length : endIndex);
  }
}
