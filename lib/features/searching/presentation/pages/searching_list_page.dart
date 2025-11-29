import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/routes.dart';
import '../bloc/searching_bloc.dart';
import '../bloc/searching_event.dart';
import '../bloc/searching_state.dart';

class SearchingListPage extends StatelessWidget {
  const SearchingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchingBloc()..add(LoadSearchingAlgorithms()),
      child: const _SearchingListContent(),
    );
  }
}

class _SearchingListContent extends StatelessWidget {
  const _SearchingListContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('categories.searching'.tr()),
      ),
      body: BlocBuilder<SearchingBloc, SearchingState>(
        builder: (context, state) {
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: state.algorithms.length,
            itemBuilder: (context, index) {
              final algorithm = state.algorithms[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12.h),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.searchingVisualizer,
                      arguments: {'algorithmId': algorithm.id},
                    );
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.search,
                                color: colorScheme.primary,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'algorithms.${algorithm.id}'.tr(),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  if (algorithm.requiresSorted)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 2.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.tertiaryContainer,
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text(
                                        'Requires Sorted Array',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: colorScheme.tertiary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          algorithm.description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            _ComplexityChip(
                              label: 'complexity.best'.tr(),
                              value: algorithm.timeComplexityBest,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8.w),
                            _ComplexityChip(
                              label: 'complexity.average'.tr(),
                              value: algorithm.timeComplexityAverage,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8.w),
                            _ComplexityChip(
                              label: 'complexity.worst'.tr(),
                              value: algorithm.timeComplexityWorst,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ComplexityChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ComplexityChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
