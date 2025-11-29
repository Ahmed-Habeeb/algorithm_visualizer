import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helper/extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/colors_manager.dart';
import '../../domain/entities/sorting_algorithm_entity.dart';
import '../bloc/sorting_bloc.dart';
import '../bloc/sorting_event.dart';
import '../bloc/sorting_state.dart';

class SortingListPage extends StatelessWidget {
  const SortingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<SortingBloc>().add(LoadSortingAlgorithms());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorting Algorithms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: () => context.toNamed(Routes.sortingComparison),
            tooltip: 'Compare Algorithms',
          ),
        ],
      ),
      body: BlocBuilder<SortingBloc, SortingState>(
        builder: (context, state) {
          if (state is SortingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SortingAlgorithmsLoaded) {
            return _buildAlgorithmList(context, state.algorithms);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAlgorithmList(
    BuildContext context,
    List<SortingAlgorithmEntity> algorithms,
  ) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select an Algorithm',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Choose a sorting algorithm to visualize',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.separated(
              itemCount: algorithms.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _AlgorithmCard(algorithm: algorithms[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AlgorithmCard extends StatelessWidget {
  final SortingAlgorithmEntity algorithm;

  const _AlgorithmCard({required this.algorithm});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          context.toNamed(
            Routes.sortingVisualizer,
            arguments: {'algorithmId': algorithm.id},
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: ColorsManager.sortingCategory.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: ColorsManager.sortingCategory,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      algorithm.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      algorithm.description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),

                    // Complexity badges
                    Wrap(
                      spacing: 8.w,
                      children: [
                        _ComplexityBadge(
                          label: algorithm.timeComplexityAverage,
                          icon: Icons.timer_outlined,
                        ),
                        _ComplexityBadge(
                          label: algorithm.spaceComplexity,
                          icon: Icons.memory,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComplexityBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ComplexityBadge({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.grey),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
