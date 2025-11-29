import '../../../core/di/base_di.dart';
import '../../../core/di/injection.dart';
import '../presentation/bloc/searching_bloc.dart';

class SearchingDI implements BaseDI {
  @override
  void registerDataSources() {
    // No data sources needed for searching
  }

  @override
  void registerRepositories() {
    // No repositories needed for searching
  }

  @override
  void registerUseCases() {
    // No use cases needed for searching
  }

  @override
  void registerBlocs() {
    // Register SearchingBloc as factory (new instance each time)
    getIt.registerFactory<SearchingBloc>(() => SearchingBloc());
  }

  @override
  void init() {
    registerDataSources();
    registerRepositories();
    registerUseCases();
    registerBlocs();
  }
}
