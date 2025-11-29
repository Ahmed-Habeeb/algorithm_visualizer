import '../../../core/di/base_di.dart';
import '../../../core/di/injection.dart';
import '../presentation/bloc/ds_bloc.dart';

class DSDI implements BaseDI {
  @override
  void registerDataSources() {}

  @override
  void registerRepositories() {}

  @override
  void registerUseCases() {}

  @override
  void registerBlocs() {
    getIt.registerFactory<DSBloc>(() => DSBloc());
  }

  @override
  void init() {
    registerDataSources();
    registerRepositories();
    registerUseCases();
    registerBlocs();
  }
}
