import 'package:get_it/get_it.dart';

import '../../../core/di/base_di.dart';
import '../presentation/bloc/sorting_bloc.dart';

class SortingDI extends BaseDI {
  final GetIt _getIt = GetIt.instance;

  @override
  void registerDataSources() {
    // Local datasource for algorithms (algorithms are defined statically)
  }

  @override
  void registerRepositories() {
    // Repository for algorithms
  }

  @override
  void registerUseCases() {
    // Use cases for running algorithms
  }

  @override
  void registerBlocs() {
    _getIt.registerFactory<SortingBloc>(() => SortingBloc());
  }
}
