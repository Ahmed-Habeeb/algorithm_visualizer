import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      // Static list of categories
      final categories = [
        const AlgorithmCategory(
          id: 'sorting',
          name: 'Sorting',
          description: 'Visualize sorting algorithms like Bubble Sort, Quick Sort, and more',
          icon: 'sort',
          algorithmCount: 6,
        ),
        const AlgorithmCategory(
          id: 'searching',
          name: 'Searching',
          description: 'Explore searching algorithms like Binary Search and Linear Search',
          icon: 'search',
          algorithmCount: 2,
        ),
        const AlgorithmCategory(
          id: 'graph',
          name: 'Graph & Pathfinding',
          description: 'Discover graph traversal and pathfinding algorithms',
          icon: 'hub',
          algorithmCount: 4,
        ),
        const AlgorithmCategory(
          id: 'data_structures',
          name: 'Data Structures',
          description: 'Visualize operations on Trees, Linked Lists, Stacks, and Queues',
          icon: 'account_tree',
          algorithmCount: 4,
        ),
        const AlgorithmCategory(
          id: 'recursion',
          name: 'Recursion',
          description: 'Understand recursive algorithms with call stack visualization',
          icon: 'replay',
          algorithmCount: 3,
        ),
        const AlgorithmCategory(
          id: 'dynamic_programming',
          name: 'Dynamic Programming',
          description: 'Learn DP with table-based visualizations',
          icon: 'grid_on',
          algorithmCount: 3,
        ),
      ];

      emit(HomeLoaded(categories));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
