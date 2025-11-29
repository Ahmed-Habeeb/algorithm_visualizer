import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helper/extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/colors_manager.dart';
import '../../../../core/utils/adaptive_layout.dart';
import '../../domain/entities/recursion_algorithm_entity.dart';
import '../bloc/recursion_bloc.dart';
import '../bloc/recursion_event.dart';
import '../bloc/recursion_state.dart';

class RecursionListPage extends StatelessWidget {
  const RecursionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecursionBloc, RecursionState>(
      builder: (context, state) {
        if (state is RecursionInitial) {
          context.read<RecursionBloc>().add(LoadAlgorithms());
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RecursionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RecursionReady) {
          return _buildContent(context, state.algorithms);
        }

        return const Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<RecursionAlgorithmEntity> algorithms,
  ) {
    final padding = AdaptiveLayout.getAdaptivePadding(context);
    final spacing = AdaptiveLayout.getSpacing(context);
    final fontMultiplier = AdaptiveLayout.getFontMultiplier(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recursion'),
      ),
      body: ConstrainedContent(
        maxWidth: 1200,
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recursion Algorithms',
              style: TextStyle(
                fontSize: 24 * fontMultiplier,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8 * fontMultiplier),
            Text(
              'Visualize recursive algorithms with call trees and stack frames',
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
                    mobileCols: 1,
                    tabletCols: 2,
                    desktopCols: 3,
                  ),
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 1.5,
                ),
                itemCount: algorithms.length,
                itemBuilder: (context, index) {
                  return _AlgorithmCard(algorithm: algorithms[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlgorithmCard extends StatelessWidget {
  final RecursionAlgorithmEntity algorithm;

  const _AlgorithmCard({required this.algorithm});

  @override
  Widget build(BuildContext context) {
    final fontMultiplier = AdaptiveLayout.getFontMultiplier(context);
    final color = ColorsManager.recursionCategory;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.toNamed(
          Routes.recursionVisualizer,
          arguments: algorithm.id,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getAlgorithmIcon(algorithm.type),
                      color: color,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                algorithm.name,
                style: TextStyle(
                  fontSize: 16 * fontMultiplier,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  algorithm.description,
                  style: TextStyle(
                    fontSize: 12 * fontMultiplier,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildComplexityChip(
                    context,
                    'Time',
                    algorithm.timeComplexity,
                    color,
                  ),
                  const SizedBox(width: 8),
                  _buildComplexityChip(
                    context,
                    'Space',
                    algorithm.spaceComplexity,
                    color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAlgorithmIcon(RecursionAlgorithmType type) {
    switch (type) {
      case RecursionAlgorithmType.fibonacci:
        return Icons.looks_one;
      case RecursionAlgorithmType.factorial:
        return Icons.calculate;
      case RecursionAlgorithmType.towerOfHanoi:
        return Icons.stacked_bar_chart;
      case RecursionAlgorithmType.mergeSort:
        return Icons.sort;
      case RecursionAlgorithmType.nQueens:
        return Icons.grid_on;
    }
  }

  Widget _buildComplexityChip(
    BuildContext context,
    String label,
    String complexity,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $complexity',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
