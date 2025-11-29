import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helper/cache_helper.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final CacheHelper _cacheHelper;

  SettingsBloc(this._cacheHelper) : super(SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeTheme>(_onChangeTheme);
    on<ChangeLocale>(_onChangeLocale);
    on<ChangeDefaultSpeed>(_onChangeDefaultSpeed);
  }

  void _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) {
    emit(SettingsState(
      themeMode: _cacheHelper.getThemeMode(),
      locale: _cacheHelper.getLocale(),
      defaultSpeed: _cacheHelper.getAnimationSpeed(),
    ));
  }

  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<SettingsState> emit,
  ) async {
    await _cacheHelper.setThemeMode(event.themeMode);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onChangeLocale(
    ChangeLocale event,
    Emitter<SettingsState> emit,
  ) async {
    await _cacheHelper.setLocale(event.locale);
    emit(state.copyWith(locale: event.locale));
  }

  Future<void> _onChangeDefaultSpeed(
    ChangeDefaultSpeed event,
    Emitter<SettingsState> emit,
  ) async {
    await _cacheHelper.setAnimationSpeed(event.speed);
    emit(state.copyWith(defaultSpeed: event.speed));
  }
}
