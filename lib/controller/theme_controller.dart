import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeController extends GetxController {
  static const String _settingsBoxName = 'theme_settings';

  final RxBool isDarkMode = false.obs;
  final RxBool notificationsEnabled = true.obs;

  late Box _settingsBox;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeSettings();
    _loadSettings();
  }

  Future<void> _initializeSettings() async {
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  void _loadSettings() {
    isDarkMode.value = _settingsBox.get('isDarkMode', defaultValue: false);
    notificationsEnabled.value =
        _settingsBox.get('notificationsEnabled', defaultValue: true);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _settingsBox.put('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
    _settingsBox.put('notificationsEnabled', notificationsEnabled.value);
  }

  @override
  void onClose() {
    _settingsBox.close();
    super.onClose();
  }
}
