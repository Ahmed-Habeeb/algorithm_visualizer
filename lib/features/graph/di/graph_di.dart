import '../../../core/di/base_di.dart';
import '../../../core/di/injection.dart';
import '../presentation/bloc/comparison_bloc.dart';
import '../presentation/bloc/grid_bloc.dart';

class GraphDI implements BaseDI {
  @override
  void registerDataSources() {
    // No data sources needed for graph
  }

  @override
  void registerRepositories() {
    // No repositories needed for graph
  }

  @override
  void registerUseCases() {
    // No use cases needed for graph
  }

  @override
  void registerBlocs() {
    // Register GridBloc as factory (new instance each time)
    getIt.registerFactory<GridBloc>(() => GridBloc());
    // Register ComparisonGridBloc for comparison feature
    getIt.registerFactory<ComparisonGridBloc>(() => ComparisonGridBloc());
  }

  @override
  void init() {
    registerDataSources();
    registerRepositories();
    registerUseCases();
    registerBlocs();
  }
}
