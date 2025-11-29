import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String themeMode;
  final String locale;
  final double defaultSpeed;

  const SettingsState({
    required this.themeMode,
    required this.locale,
    required this.defaultSpeed,
  });

  factory SettingsState.initial() => const SettingsState(
        themeMode: 'system',
        locale: 'en',
        defaultSpeed: 1.0,
      );

  SettingsState copyWith({
    String? themeMode,
    String? locale,
    double? defaultSpeed,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      defaultSpeed: defaultSpeed ?? this.defaultSpeed,
    );
  }

  @override
  List<Object?> get props => [themeMode, locale, defaultSpeed];
}
