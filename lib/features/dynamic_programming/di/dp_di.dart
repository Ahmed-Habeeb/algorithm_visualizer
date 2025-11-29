import 'package:get_it/get_it.dart';

import '../../../core/di/base_di.dart';
import '../presentation/bloc/dp_bloc.dart';

class DPDI extends BaseDI {
  final GetIt _getIt = GetIt.instance;

  @override
  void registerDataSources() {
    // Algorithms are defined statically
  }

  @override
  void registerRepositories() {
    // No repositories needed
  }

  @override
  void registerUseCases() {
    // No use cases needed
  }

  @override
  void registerBlocs() {
    _getIt.registerFactory<DPBloc>(() => DPBloc());
  }
}
