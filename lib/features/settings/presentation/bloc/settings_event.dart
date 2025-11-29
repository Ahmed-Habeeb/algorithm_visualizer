sealed class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class ChangeTheme extends SettingsEvent {
  final String themeMode; // 'light', 'dark', 'system'

  ChangeTheme(this.themeMode);
}

class ChangeLocale extends SettingsEvent {
  final String locale; // 'en', 'ar'

  ChangeLocale(this.locale);
}

class ChangeDefaultSpeed extends SettingsEvent {
  final double speed;

  ChangeDefaultSpeed(this.speed);
}
