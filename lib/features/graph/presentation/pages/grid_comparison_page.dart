import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/adaptive_layout.dart';
import '../../../../core/widgets/playback_controls.dart';
import '../../../../core/widgets/speed_slider.dart';
import '../bloc/comparison_bloc.dart';
import '../widgets/algorithm_selector.dart';
import '../widgets/comparison_grid_panel.dart';
import '../widgets/comparison_metrics_panel.dart';
import '../widgets/grid_visualizer.dart';

class GridComparisonPage extends StatefulWidget {
  const GridComparisonPage({super.key});

  @override
  State<GridComparisonPage> createState() => _GridComparisonPageState();
}

class _GridComparisonPageState extends State<GridComparisonPage> {
  GridInteractionMode _mode = GridInteractionMode.drawObstacle;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComparisonGridBloc, ComparisonState>(
      builder: (context, state) {
        if (state is ComparisonInitial) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ComparisonReady) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Algorithm Comparison'),
              centerTitle: AdaptiveLayout.isDesktop(context),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      context.read<ComparisonGridBloc>().add(ClearComparisonVisualization()),
                  tooltip: 'Reset Visualization',
                ),
              ],
            ),
            body: _buildBody(context, state),
          );
        }

        if (state is ComparisonError) {
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

  Widget _buildBody(BuildContext context, ComparisonReady state) {
    final isDesktop = AdaptiveLayout.isDesktop(context);
    final isTablet = AdaptiveLayout.isTablet(context);

    if (isDesktop || isTablet) {
      return _buildWideLayout(context, state, isDesktop);
    }
    return _buildMobileLayout(context, state);
  }

  Widget _buildWideLayout(BuildContext context, ComparisonReady state, bool isDesktop) {
    final spacing = AdaptiveLayout.getSpacing(context);
    final selectedAlgorithms = state.selectedAlgorithmIds.toList();

    return ConstrainedContent(
      maxWidth: isDesktop ? 1800 : 1400,
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          children: [
            // Algorithm Grids Row
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
                onStepBack: () =>
                    context.read<ComparisonGridBloc>().add(StepComparisonBackward()),
                onStepForward: () =>
                    context.read<ComparisonGridBloc>().add(StepComparisonForward()),
                onReset: () => context.read<ComparisonGridBloc>().add(ResetComparison()),
                onSkipToEnd: () => context
                    .read<ComparisonGridBloc>()
                    .add(SetComparisonStep(state.maxSteps - 1)),
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
                  child: AlgorithmSelector(
                    availableAlgorithms: state.availableAlgorithms,
                    selectedAlgorithmIds: state.selectedAlgorithmIds,
                    onSelectionChanged: (id, selected) => context
                        .read<ComparisonGridBloc>()
                        .add(SelectAlgorithm(id, selected)),
                  ),
                ),
                SizedBox(width: spacing),

                // Grid Controls (for editing grid)
                Expanded(
                  child: _buildGridEditor(context, state),
                ),
                SizedBox(width: spacing),

                // Metrics Panel
                Expanded(
                  flex: 2,
                  child: ComparisonMetricsPanel(
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

  Widget _buildMobileLayout(BuildContext context, ComparisonReady state) {
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
              onStepBack: () =>
                  context.read<ComparisonGridBloc>().add(StepComparisonBackward()),
              onStepForward: () =>
                  context.read<ComparisonGridBloc>().add(StepComparisonForward()),
              onReset: () => context.read<ComparisonGridBloc>().add(ResetComparison()),
              onSkipToEnd: () => context
                  .read<ComparisonGridBloc>()
                  .add(SetComparisonStep(state.maxSteps - 1)),
            ),
            SizedBox(height: spacing),
          ],

          // Algorithm Selector
          AlgorithmSelector(
            availableAlgorithms: state.availableAlgorithms,
            selectedAlgorithmIds: state.selectedAlgorithmIds,
            onSelectionChanged: (id, selected) => context
                .read<ComparisonGridBloc>()
                .add(SelectAlgorithm(id, selected)),
            compact: true,
          ),
          SizedBox(height: spacing),

          // Grid Editor
          _buildGridEditor(context, state),
          SizedBox(height: spacing),

          // Speed Slider
          SpeedSlider(
            speed: state.speed,
            onSpeedChanged: (speed) =>
                context.read<ComparisonGridBloc>().add(SetComparisonSpeed(speed)),
          ),
          SizedBox(height: spacing),

          // Metrics Panel
          ComparisonMetricsPanel(
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
    ComparisonReady state,
    String algorithmId,
  ) {
    final algorithm = state.availableAlgorithms.firstWhere(
      (a) => a.id == algorithmId,
      orElse: () => state.availableAlgorithms.first,
    );

    final frame = state.getFrameForAlgorithm(algorithmId);
    final frames = state.algorithmFrames[algorithmId];
    final isFinished =
        frames != null && frames.isNotEmpty && state.currentStep >= frames.length - 1;

    return ComparisonGridPanel(
      algorithmId: algorithmId,
      algorithmName: algorithm.name,
      grid: state.grid,
      frame: frame,
      isFinished: isFinished,
      accentColor: getAlgorithmColor(algorithmId),
    );
  }

  Widget _buildGridEditor(BuildContext context, ComparisonReady state) {
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
            'Grid Editor',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Mode Selection
          Row(
            children: [
              _buildModeButton(
                context,
                GridInteractionMode.drawObstacle,
                Icons.square,
                'Draw',
              ),
              const SizedBox(width: 8),
              _buildModeButton(
                context,
                GridInteractionMode.eraseObstacle,
                Icons.square_outlined,
                'Erase',
              ),
              const SizedBox(width: 8),
              _buildModeButton(
                context,
                GridInteractionMode.setStart,
                Icons.play_arrow,
                'Start',
              ),
              const SizedBox(width: 8),
              _buildModeButton(
                context,
                GridInteractionMode.setEnd,
                Icons.flag,
                'End',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Grid Preview
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: GridVisualizer(
                grid: state.grid,
                frame: null,
                mode: _mode,
                onCellTap: (x, y) => _handleCellTap(context, x, y),
                onCellDrag: (x, y) => _handleCellDrag(context, x, y),
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
                      ? () => context.read<ComparisonGridBloc>().add(RunComparison())
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
                  onPressed: () =>
                      context.read<ComparisonGridBloc>().add(ClearComparisonGrid()),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context
                      .read<ComparisonGridBloc>()
                      .add(ClearComparisonVisualization()),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Clear Path'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    GridInteractionMode mode,
    IconData icon,
    String label,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _mode == mode;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _mode = mode),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSlider(BuildContext context, ComparisonReady state) {
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
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
              context.read<ComparisonGridBloc>().add(SetComparisonStep(value.toInt()));
            },
          ),
        ],
      ),
    );
  }

  void _handleCellTap(BuildContext context, int x, int y) {
    switch (_mode) {
      case GridInteractionMode.drawObstacle:
        context.read<ComparisonGridBloc>().add(ToggleComparisonObstacle(x, y));
        break;
      case GridInteractionMode.eraseObstacle:
        context.read<ComparisonGridBloc>().add(RemoveComparisonObstacle(x, y));
        break;
      case GridInteractionMode.setStart:
        context.read<ComparisonGridBloc>().add(SetComparisonStart(x, y));
        break;
      case GridInteractionMode.setEnd:
        context.read<ComparisonGridBloc>().add(SetComparisonEnd(x, y));
        break;
    }
  }

  void _handleCellDrag(BuildContext context, int x, int y) {
    switch (_mode) {
      case GridInteractionMode.drawObstacle:
        context.read<ComparisonGridBloc>().add(AddComparisonObstacle(x, y));
        break;
      case GridInteractionMode.eraseObstacle:
        context.read<ComparisonGridBloc>().add(RemoveComparisonObstacle(x, y));
        break;
      default:
        break;
    }
  }

  void _togglePlayPause(BuildContext context, ComparisonReady state) {
    if (state.isPlaying) {
      context.read<ComparisonGridBloc>().add(PauseComparison());
    } else {
      context.read<ComparisonGridBloc>().add(PlayComparison());
    }
  }
}
