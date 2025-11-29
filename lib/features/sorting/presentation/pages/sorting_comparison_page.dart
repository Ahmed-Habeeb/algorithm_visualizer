import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/adaptive_layout.dart';
import '../../../../core/widgets/playback_controls.dart';
import '../../../../core/widgets/speed_slider.dart';
import '../bloc/sorting_comparison_bloc.dart';
import '../widgets/comparison_array_panel.dart';
import '../widgets/sorting_algorithm_selector.dart';
import '../widgets/sorting_comparison_metrics_panel.dart';

class SortingComparisonPage extends StatefulWidget {
  const SortingComparisonPage({super.key});

  @override
  State<SortingComparisonPage> createState() => _SortingComparisonPageState();
}

class _SortingComparisonPageState extends State<SortingComparisonPage> {
  int _arraySize = 20;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SortingComparisonBloc, SortingComparisonState>(
      builder: (context, state) {
        if (state is SortingComparisonInitial) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is SortingComparisonReady) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Sorting Comparison'),
              centerTitle: AdaptiveLayout.isDesktop(context),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context
                      .read<SortingComparisonBloc>()
                      .add(ClearSortingComparison()),
                  tooltip: 'Reset Visualization',
                ),
              ],
            ),
            body: _buildBody(context, state),
          );
        }

        if (state is SortingComparisonError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(state.message)),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('Something went wrong')),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SortingComparisonReady state) {
    final isDesktop = AdaptiveLayout.isDesktop(context);
    final isTablet = AdaptiveLayout.isTablet(context);

    if (isDesktop || isTablet) {
      return _buildWideLayout(context, state, isDesktop);
    }
    return _buildMobileLayout(context, state);
  }

  Widget _buildWideLayout(
      BuildContext context, SortingComparisonReady state, bool isDesktop) {
    final spacing = AdaptiveLayout.getSpacing(context);
    final selectedAlgorithms = state.selectedAlgorithmIds.toList();

    return ConstrainedContent(
      maxWidth: isDesktop ? 1800 : 1400,
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          children: [
            // Algorithm Array Panels Row
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  for (int i = 0; i < selectedAlgorithms.length; i++) ...[
                    if (i > 0) SizedBox(width: spacing / 2),
                    Expanded(
                      child: _buildAlgorithmPanel(
                        context,
                        state,
                        selectedAlgorithms[i],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: spacing),

            // Progress Slider and Playback
            if (state.hasRun && state.maxSteps > 0) ...[
              _buildProgressSlider(context, state),
              SizedBox(height: spacing / 2),
              PlaybackControls(
                isPlaying: state.isPlaying,
                canStepBack: state.canStepBackward,
                canStepForward: state.canStepForward,
                onPlayPause: () => _togglePlayPause(context, state),
                onStepBack: () => context
                    .read<SortingComparisonBloc>()
                    .add(StepSortingBackward()),
                onStepForward: () => context
                    .read<SortingComparisonBloc>()
                    .add(StepSortingForward()),
                onReset: () => context
                    .read<SortingComparisonBloc>()
                    .add(ResetSortingComparison()),
                onSkipToEnd: () => context
                    .read<SortingComparisonBloc>()
                    .add(SetSortingComparisonStep(state.maxSteps - 1)),
              ),
              SizedBox(height: spacing),
            ],

            // Bottom Controls Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Algorithm Selector
                SizedBox(
                  width: isDesktop ? 280 : 240,
                  child: SortingAlgorithmSelector(
                    availableAlgorithms: state.availableAlgorithms,
                    selectedAlgorithmIds: state.selectedAlgorithmIds,
                    onSelectionChanged: (id, selected) => context
                        .read<SortingComparisonBloc>()
                        .add(SelectSortingAlgorithm(id, selected)),
                  ),
                ),
                SizedBox(width: spacing),

                // Array Controls
                Expanded(
                  child: _buildArrayControls(context, state),
                ),
                SizedBox(width: spacing),

                // Metrics Panel
                Expanded(
                  flex: 2,
                  child: SortingComparisonMetricsPanel(
                    results: state.results,
                    algorithmOrder: selectedAlgorithms,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, SortingComparisonReady state) {
    final spacing = AdaptiveLayout.getSpacing(context);
    final padding = AdaptiveLayout.getAdaptivePadding(context);
    final selectedAlgorithms = state.selectedAlgorithmIds.toList();

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        children: [
          // 2x2 Grid for algorithms
          AspectRatio(
            aspectRatio: 1.0,
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: spacing / 2,
              crossAxisSpacing: spacing / 2,
              children: selectedAlgorithms
                  .map((id) => _buildAlgorithmPanel(context, state, id))
                  .toList(),
            ),
          ),
          SizedBox(height: spacing),

          // Progress and Playback
          if (state.hasRun && state.maxSteps > 0) ...[
            _buildProgressSlider(context, state),
            SizedBox(height: spacing / 2),
            PlaybackControls(
              isPlaying: state.isPlaying,
              canStepBack: state.canStepBackward,
              canStepForward: state.canStepForward,
              onPlayPause: () => _togglePlayPause(context, state),
              onStepBack: () => context
                  .read<SortingComparisonBloc>()
                  .add(StepSortingBackward()),
              onStepForward: () => context
                  .read<SortingComparisonBloc>()
                  .add(StepSortingForward()),
              onReset: () => context
                  .read<SortingComparisonBloc>()
                  .add(ResetSortingComparison()),
              onSkipToEnd: () => context
                  .read<SortingComparisonBloc>()
                  .add(SetSortingComparisonStep(state.maxSteps - 1)),
            ),
            SizedBox(height: spacing),
          ],

          // Algorithm Selector
          SortingAlgorithmSelector(
            availableAlgorithms: state.availableAlgorithms,
            selectedAlgorithmIds: state.selectedAlgorithmIds,
            onSelectionChanged: (id, selected) => context
                .read<SortingComparisonBloc>()
                .add(SelectSortingAlgorithm(id, selected)),
            compact: true,
          ),
          SizedBox(height: spacing),

          // Array Controls
          _buildArrayControls(context, state),
          SizedBox(height: spacing),

          // Speed Slider
          SpeedSlider(
            speed: state.speed,
            onSpeedChanged: (speed) => context
                .read<SortingComparisonBloc>()
                .add(SetSortingComparisonSpeed(speed)),
          ),
          SizedBox(height: spacing),

          // Metrics Panel
          SortingComparisonMetricsPanel(
            results: state.results,
            algorithmOrder: selectedAlgorithms,
            compact: true,
          ),
          SizedBox(height: spacing),
        ],
      ),
    );
  }

  Widget _buildAlgorithmPanel(
    BuildContext context,
    SortingComparisonReady state,
    String algorithmId,
  ) {
    final algorithm = state.availableAlgorithms.firstWhere(
      (a) => a.id == algorithmId,
      orElse: () => state.availableAlgorithms.first,
    );

    final frame = state.getFrameForAlgorithm(algorithmId);
    final frames = state.algorithmFrames[algorithmId];
    final isFinished = frames != null &&
        frames.isNotEmpty &&
        state.currentStep >= frames.length - 1;

    return ComparisonArrayPanel(
      algorithmId: algorithmId,
      algorithmName: algorithm.name,
      frame: frame,
      initialData: state.inputData,
      isFinished: isFinished,
      accentColor: getSortingAlgorithmColor(algorithmId),
    );
  }

  Widget _buildArrayControls(
      BuildContext context, SortingComparisonReady state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Array Settings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // Array Size Slider
          Row(
            children: [
              Icon(Icons.straighten, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Size: $_arraySize',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Slider(
            value: _arraySize.toDouble(),
            min: 10,
            max: 50,
            divisions: 8,
            label: _arraySize.toString(),
            onChanged: (value) {
              setState(() => _arraySize = value.toInt());
            },
            onChangeEnd: (value) {
              context
                  .read<SortingComparisonBloc>()
                  .add(SetSortingArraySize(value.toInt()));
            },
          ),

          const SizedBox(height: 8),

          // Array Preview
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${state.inputData.length} elements',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.canRun && !state.isPlaying
                      ? () => context
                          .read<SortingComparisonBloc>()
                          .add(RunSortingComparison())
                      : null,
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('Run Comparison'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context
                      .read<SortingComparisonBloc>()
                      .add(RandomizeSortingArray()),
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: const Text('Randomize'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context
                      .read<SortingComparisonBloc>()
                      .add(ClearSortingComparison()),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Clear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSlider(
      BuildContext context, SortingComparisonReady state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${state.currentStep + 1}',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                '${state.maxSteps} total',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Slider(
            value: state.currentStep.toDouble(),
            min: 0,
            max: (state.maxSteps - 1).toDouble().clamp(0, double.infinity),
            divisions: state.maxSteps > 1 ? state.maxSteps - 1 : 1,
            onChanged: (value) {
              context
                  .read<SortingComparisonBloc>()
                  .add(SetSortingComparisonStep(value.toInt()));
            },
          ),
        ],
      ),
    );
  }

  void _togglePlayPause(BuildContext context, SortingComparisonReady state) {
    if (state.isPlaying) {
      context.read<SortingComparisonBloc>().add(PauseSortingComparison());
    } else {
      context.read<SortingComparisonBloc>().add(PlaySortingComparison());
    }
  }
}
