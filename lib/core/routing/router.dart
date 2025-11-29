import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/sorting/presentation/pages/sorting_list_page.dart';
import '../../features/sorting/presentation/pages/sorting_visualizer_page.dart';
import '../../features/searching/presentation/pages/searching_list_page.dart';
import '../../features/searching/presentation/pages/searching_visualizer_page.dart';
import '../../features/graph/presentation/pages/graph_list_page.dart';
import '../../features/graph/presentation/pages/grid_comparison_page.dart';
import '../../features/graph/presentation/pages/grid_visualizer_page.dart';
import '../../features/data_structures/presentation/pages/ds_list_page.dart';
import '../../features/data_structures/presentation/pages/ds_visualizer_page.dart';
import '../../features/recursion/presentation/pages/recursion_list_page.dart';
import '../../features/recursion/presentation/pages/recursion_visualizer_page.dart';
import '../../features/dynamic_programming/presentation/pages/dp_list_page.dart';
import '../../features/dynamic_programming/presentation/pages/dp_visualizer_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/sorting/presentation/bloc/sorting_bloc.dart';
import '../../features/searching/presentation/bloc/searching_bloc.dart';
import '../../features/graph/presentation/bloc/comparison_bloc.dart';
import '../../features/graph/presentation/bloc/grid_bloc.dart';
import '../../features/data_structures/presentation/bloc/ds_bloc.dart';
import '../../features/recursion/presentation/bloc/recursion_bloc.dart';
import '../../features/dynamic_programming/presentation/bloc/dp_bloc.dart';
import '../di/injection.dart';
import 'routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _buildRoute(const SplashPage(), settings);

      case Routes.home:
        return _buildRoute(const HomePage(), settings);

      case Routes.sortingList:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<SortingBloc>(),
            child: const SortingListPage(),
          ),
          settings,
        );

      case Routes.sortingVisualizer:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<SortingBloc>(),
            child: SortingVisualizerPage(
              algorithmId: args['algorithmId'] as String,
            ),
          ),
          settings,
        );

      case Routes.settings:
        return _buildRoute(const SettingsPage(), settings);

      case Routes.searchingList:
        return _buildRoute(const SearchingListPage(), settings);

      case Routes.searchingVisualizer:
        final args = settings.arguments as Map<String, dynamic>;
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<SearchingBloc>(),
            child: SearchingVisualizerPage(
              algorithmId: args['algorithmId'] as String,
            ),
          ),
          settings,
        );

      case Routes.graphList:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<GridBloc>(),
            child: GraphListPage(),
          ),
          settings,
        );

      case Routes.graphVisualizer:
        final algorithmId = settings.arguments as String;
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<GridBloc>(),
            child: GridVisualizerPage(
              algorithmId: algorithmId,
            ),
          ),
          settings,
        );

      case Routes.graphComparison:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<ComparisonGridBloc>(),
            child: const GridComparisonPage(),
          ),
          settings,
        );

      case Routes.dataStructuresList:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<DSBloc>(),
            child: DSListPage(),
          ),
          settings,
        );

      case Routes.dataStructuresVisualizer:
        final structureId = settings.arguments as String;
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<DSBloc>(),
            child: DSVisualizerPage(
              structureId: structureId,
            ),
          ),
          settings,
        );

      case Routes.recursionList:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<RecursionBloc>(),
            child: const RecursionListPage(),
          ),
          settings,
        );

      case Routes.recursionVisualizer:
        final algorithmId = settings.arguments as String;
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<RecursionBloc>(),
            child: RecursionVisualizerPage(
              algorithmId: algorithmId,
            ),
          ),
          settings,
        );

      case Routes.dpList:
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<DPBloc>(),
            child: const DPListPage(),
          ),
          settings,
        );

      case Routes.dpVisualizer:
        final algorithmId = settings.arguments as String;
        return _buildRoute(
          BlocProvider(
            create: (_) => getIt<DPBloc>(),
            child: DPVisualizerPage(
              algorithmId: algorithmId,
            ),
          ),
          settings,
        );

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
