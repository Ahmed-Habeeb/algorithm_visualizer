import 'package:get_it/get_it.dart';

import '../../../core/di/base_di.dart';
import '../presentation/bloc/home_bloc.dart';

class HomeDI extends BaseDI {
  final GetIt _getIt = GetIt.instance;

  @override
  void registerDataSources() {
    // No data sources for home
  }

  @override
  void registerRepositories() {
    // No repositories for home
  }

  @override
  void registerUseCases() {
    // No use cases for home
  }

  @override
  void registerBlocs() {
    _getIt.registerFactory<HomeBloc>(() => HomeBloc());
  }
}
