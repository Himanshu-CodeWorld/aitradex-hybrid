import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_theme.dart';
import 'package:aitradex/services/shared_preferences_service.dart';

class ThemeController extends GetxController {
  // ===========================================================================
  // OBSERVABLE VALUES
  // ===========================================================================

  /// Current application primary color.
  final Rx<Color> primaryColor =
      const Color(0xFF18C48F).obs;

  /// Whether dark mode is currently enabled.
  final RxBool isDarkMode = false.obs;

  // ===========================================================================
  // STORAGE KEYS
  // ===========================================================================

  static const String _primaryColorKey = 'app_primary_color';
  static const String _darkModeKey = 'app_dark_mode';

  // ===========================================================================
  // DEFAULT VALUES
  // ===========================================================================

  static const Color _defaultPrimaryColor =
  Color(0xFF18C48F);

  static const bool _defaultDarkMode = false;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void onInit() {
    super.onInit();

    _loadTheme();
  }

  // ===========================================================================
  // LOAD SAVED THEME
  // ===========================================================================

  Future<void> _loadTheme() async {
    try {
      // -----------------------------------------------------------------------
      // LOAD PRIMARY COLOR
      // -----------------------------------------------------------------------

      final String? savedColor =
      await SharedPreferencesService.getString(
        _primaryColorKey,
      );

      if (savedColor != null && savedColor.isNotEmpty) {
        final int? colorValue =
        int.tryParse(savedColor);

        if (colorValue != null) {
          primaryColor.value = Color(colorValue);
        }
      }

      // -----------------------------------------------------------------------
      // LOAD DARK MODE
      // -----------------------------------------------------------------------

      final bool savedDarkMode =
          await SharedPreferencesService.getBool(
            _darkModeKey,
          ) ??
              _defaultDarkMode;

      isDarkMode.value = savedDarkMode;

      // -----------------------------------------------------------------------
      // APPLY SAVED THEME
      // -----------------------------------------------------------------------

      _applyTheme();
    } catch (e, stackTrace) {
      debugPrint(
        '========================================',
      );
      debugPrint(
        '❌ THEME LOAD ERROR',
      );
      debugPrint(
        'Error: $e',
      );
      debugPrint(
        'StackTrace: $stackTrace',
      );
      debugPrint(
        '========================================',
      );

      // -----------------------------------------------------------------------
      // SAFE DEFAULTS
      // -----------------------------------------------------------------------

      primaryColor.value =
          _defaultPrimaryColor;

      isDarkMode.value =
          _defaultDarkMode;

      _applyTheme();
    }
  }

  // ===========================================================================
  // SET PRIMARY COLOR
  // ===========================================================================

  Future<void> setPrimaryColor(
      Color color,
      ) async {
    // Update UI immediately.
    primaryColor.value = color;

    // Save selected color.
    try {
      await SharedPreferencesService.saveString(
        _primaryColorKey,
        color.toARGB32().toString(),
      );
    } catch (e) {
      debugPrint(
        '❌ THEME COLOR SAVE ERROR: $e',
      );
    }

    // Apply theme immediately.
    _applyTheme();
  }

  // ===========================================================================
  // SET DARK MODE
  // ===========================================================================

  Future<void> setDarkMode(
      bool value,
      ) async {
    // Update UI immediately.
    isDarkMode.value = value;

    // Save preference.
    try {
      await SharedPreferencesService.saveBool(
        _darkModeKey,
        value,
      );
    } catch (e) {
      debugPrint(
        '❌ DARK MODE SAVE ERROR: $e',
      );
    }

    // Apply theme immediately.
    _applyTheme();
  }

  // ===========================================================================
  // TOGGLE DARK MODE
  // ===========================================================================

  Future<void> toggleDarkMode() async {
    await setDarkMode(
      !isDarkMode.value,
    );
  }

  // ===========================================================================
  // APPLY THEME
  // ===========================================================================

  void _applyTheme() {
    try {
      final ThemeData theme;

      if (isDarkMode.value) {
        theme = AppTheme.darkTheme(
          primaryColor.value,
        );
      } else {
        theme = AppTheme.lightTheme(
          primaryColor.value,
        );
      }

      Get.changeTheme(theme);
    } catch (e) {
      debugPrint(
        '❌ APPLY THEME ERROR: $e',
      );
    }
  }

  // ===========================================================================
  // RESET THEME
  // ===========================================================================

  Future<void> resetTheme() async {
    primaryColor.value =
        _defaultPrimaryColor;

    isDarkMode.value =
        _defaultDarkMode;

    try {
      await SharedPreferencesService.saveString(
        _primaryColorKey,
        _defaultPrimaryColor
            .toARGB32()
            .toString(),
      );

      await SharedPreferencesService.saveBool(
        _darkModeKey,
        _defaultDarkMode,
      );
    } catch (e) {
      debugPrint(
        '❌ THEME RESET SAVE ERROR: $e',
      );
    }

    _applyTheme();
  }
}