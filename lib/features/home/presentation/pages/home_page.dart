import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helper/extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/colors_manager.dart';
import '../../../../core/utils/adaptive_layout.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(LoadCategories()),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algorithm Visualizer'),
        centerTitle: AdaptiveLayout.isDesktop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.toNamed(Routes.settings),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is HomeLoaded) {
            return _buildCategoryGrid(context, state.categories);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    List<AlgorithmCategory> categories,
  ) {
    final padding = AdaptiveLayout.getAdaptivePadding(context);
    final spacing = AdaptiveLayout.getSpacing(context);
    final isDesktop = AdaptiveLayout.isDesktop(context);
    final fontMultiplier = AdaptiveLayout.getFontMultiplier(context);

    return ConstrainedContent(
      maxWidth: 1600,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a Category',
            style: TextStyle(
              fontSize: 24 * fontMultiplier,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8 * fontMultiplier),
          Text(
            'Explore different algorithm categories',
            style: TextStyle(
              fontSize: 14 * fontMultiplier,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: spacing * 1.5),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AdaptiveLayout.getGridCrossAxisCount(
                  context,
                  mobileCols: 2,
                  tabletCols: 2,
                  desktopCols: 3,
                  largeCols: 4,
                ),
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: isDesktop ? 1.2 : 1.0,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _CategoryCard(category: categories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AlgorithmCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category.id);
    final fontMultiplier = AdaptiveLayout.getFontMultiplier(context);
    final isDesktop = AdaptiveLayout.isDesktop(context);
    final spacing = AdaptiveLayout.getSpacing(context, baseSpacing: 12);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToCategory(context, category.id),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: isDesktop ? 56 : 48,
                height: isDesktop ? 56 : 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(category.id),
                  color: color,
                  size: isDesktop ? 28 : 24,
                ),
              ),
              SizedBox(height: spacing),

              // Title
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 16 * fontMultiplier,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4 * fontMultiplier),

              // Description
              Expanded(
                child: Text(
                  category.description,
                  style: TextStyle(
                    fontSize: 12 * fontMultiplier,
                    color: Colors.grey,
                  ),
                  maxLines: isDesktop ? 3 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Algorithm count
              Row(
                children: [
                  Icon(
                    Icons.code,
                    size: 14 * fontMultiplier,
                    color: color,
                  ),
                  SizedBox(width: 4 * fontMultiplier),
                  Text(
                    '${category.algorithmCount} algorithms',
                    style: TextStyle(
                      fontSize: 12 * fontMultiplier,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String categoryId) {
    switch (categoryId) {
      case 'sorting':
        context.toNamed(Routes.sortingList);
        break;
      case 'searching':
        context.toNamed(Routes.searchingList);
        break;
      case 'graph':
        context.toNamed(Routes.graphList);
        break;
      case 'data_structures':
        context.toNamed(Routes.dataStructuresList);
        break;
      case 'recursion':
        context.toNamed(Routes.recursionList);
        break;
      case 'dynamic_programming':
        context.toNamed(Routes.dpList);
        break;
    }
  }

  Color _getCategoryColor(String categoryId) {
    switch (categoryId) {
      case 'sorting':
        return ColorsManager.sortingCategory;
      case 'searching':
        return ColorsManager.searchingCategory;
      case 'graph':
        return ColorsManager.graphCategory;
      case 'data_structures':
        return ColorsManager.dataStructuresCategory;
      case 'recursion':
        return ColorsManager.recursionCategory;
      case 'dynamic_programming':
        return ColorsManager.dpCategory;
      default:
        return ColorsManager.primaryColor;
    }
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'sorting':
        return Icons.sort;
      case 'searching':
        return Icons.search;
      case 'graph':
        return Icons.hub;
      case 'data_structures':
        return Icons.account_tree;
      case 'recursion':
        return Icons.replay;
      case 'dynamic_programming':
        return Icons.grid_on;
      default:
        return Icons.code;
    }
  }
}
