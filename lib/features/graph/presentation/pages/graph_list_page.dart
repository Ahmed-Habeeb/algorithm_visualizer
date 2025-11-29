import 'package:flutter/material.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/utils/adaptive_layout.dart';
import '../../data/algorithms/a_star.dart';
import '../../data/algorithms/bfs.dart';
import '../../data/algorithms/dfs.dart';
import '../../data/algorithms/dijkstra.dart';
import '../../domain/interfaces/graph_algorithm.dart';

class GraphListPage extends StatelessWidget {
  GraphListPage({super.key});

  final List<GraphAlgorithm> _algorithms = [
    BFS(),
    DFS(),
    Dijkstra(),
    AStar(),
  ];

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = AdaptiveLayout.getGridCrossAxisCount(
      context,
      mobileCols: 1,
      tabletCols: 2,
      desktopCols: 2,
    );
    final spacing = AdaptiveLayout.getSpacing(context);
    final padding = AdaptiveLayout.getAdaptivePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Algorithms'),
        centerTitle: AdaptiveLayout.isDesktop(context),
      ),
      body: ConstrainedContent(
        maxWidth: 1200,
        child: GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: AdaptiveLayout.isMobile(context) ? 2.5 : 2.0,
          ),
          itemCount: _algorithms.length,
          itemBuilder: (context, index) {
            final algorithm = _algorithms[index].algorithm;
            return _AlgorithmCard(
              name: algorithm.name,
              description: algorithm.description,
              timeComplexity: algorithm.timeComplexity,
              spaceComplexity: algorithm.spaceComplexity,
              onTap: () => Navigator.pushNamed(
                context,
                Routes.graphVisualizer,
                arguments: algorithm.id,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AlgorithmCard extends StatelessWidget {
  final String name;
  final String description;
  final String timeComplexity;
  final String spaceComplexity;
  final VoidCallback onTap;

  const _AlgorithmCard({
    required this.name,
    required this.description,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.hub,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _ComplexityChip(
                    label: timeComplexity,
                    icon: Icons.timer_outlined,
                  ),
                  _ComplexityChip(
                    label: spaceComplexity,
                    icon: Icons.memory,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComplexityChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ComplexityChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
