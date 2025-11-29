import 'package:get_it/get_it.dart';

import '../../../core/di/base_di.dart';
import '../../../core/helper/cache_helper.dart';
import '../presentation/bloc/settings_bloc.dart';

class SettingsDI extends BaseDI {
  final GetIt _getIt = GetIt.instance;

  @override
  void registerDataSources() {}

  @override
  void registerRepositories() {}

  @override
  void registerUseCases() {}

  @override
  void registerBlocs() {
    _getIt.registerFactory<SettingsBloc>(
      () => SettingsBloc(_getIt<CacheHelper>()),
    );
  }
}
