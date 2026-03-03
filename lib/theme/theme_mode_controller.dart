import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light/light.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';

const _themePreferenceKey = 'theme_mode_preference';

enum AppThemePreference { light, dark, auto }

class ThemeModeState {
  final AppThemePreference preference;
  final bool isDarkBySensor;

  const ThemeModeState({
    required this.preference,
    required this.isDarkBySensor,
  });

  ThemeMode get materialThemeMode {
    switch (preference) {
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.auto:
        return isDarkBySensor ? ThemeMode.dark : ThemeMode.light;
    }
  }

  ThemeModeState copyWith({
    AppThemePreference? preference,
    bool? isDarkBySensor,
  }) {
    return ThemeModeState(
      preference: preference ?? this.preference,
      isDarkBySensor: isDarkBySensor ?? this.isDarkBySensor,
    );
  }
}

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeModeState>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeModeState> {
  StreamSubscription<int>? _lightSubscription;
  final Light _lightSensor = Light();

  @override
  ThemeModeState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(_themePreferenceKey);

    final preference = AppThemePreference.values.firstWhere(
      (item) => item.name == stored,
      orElse: () => AppThemePreference.auto,
    );

    ref.onDispose(() {
      _lightSubscription?.cancel();
    });

    final initialState = ThemeModeState(
      preference: preference,
      isDarkBySensor: false,
    );

    state = initialState;

    _bindSensorStreamIfNeeded();

    return initialState;
  }

  Future<void> setPreference(AppThemePreference next) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_themePreferenceKey, next.name);

    state = state.copyWith(preference: next);

    if (next == AppThemePreference.auto) {
      _bindSensorStreamIfNeeded();
    } else {
      _disposeSensorStream();
    }
  }

  void _bindSensorStreamIfNeeded() {
    if (state.preference != AppThemePreference.auto) {
      _disposeSensorStream();
      return;
    }

    if (_lightSubscription != null) {
      return;
    }

    try {
      _lightSubscription = _lightSensor.lightSensorStream.listen(
        (lux) {
          final shouldUseDark = lux < 20;
          if (shouldUseDark != state.isDarkBySensor) {
            state = state.copyWith(isDarkBySensor: shouldUseDark);
          }
        },
        onError: (_) {
          // Keep the last known state if sensor errors.
        },
      );
    } on PlatformException {
      // Light sensor may be unavailable on some devices.
    }
  }

  void _disposeSensorStream() {
    _lightSubscription?.cancel();
    _lightSubscription = null;
  }
}
