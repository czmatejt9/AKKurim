import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends ChangeNotifier {
  bool _themeMode = true;

  ColorScheme get colorScheme =>
      _themeMode ? const ColorScheme.dark() : const ColorScheme.light();

  void changeTheme() {
    _themeMode = !_themeMode;
    notifyListeners();
    saveTheme();
  }

  void loadTheme() {
    final box = GetStorage();
    _themeMode = box.read('theme') ?? true;
  }

  void saveTheme() {
    final box = GetStorage();
    box.write('theme', _themeMode);
  }
}
