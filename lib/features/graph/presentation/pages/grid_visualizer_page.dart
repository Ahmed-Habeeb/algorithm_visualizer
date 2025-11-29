import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/utils/adaptive_layout.dart';
import '../../../../core/widgets/playback_controls.dart';
import '../../../../core/widgets/speed_slider.dart';
import '../bloc/grid_bloc.dart';
import '../widgets/grid_controls.dart';
import '../widgets/grid_graph_view.dart';
import '../widgets/grid_legend.dart';
import '../widgets/grid_stats_panel.dart';
import '../widgets/grid_visualizer.dart';

class GridVisualizerPage extends StatefulWidget {
  final String algorithmId;

  const GridVisualizerPage({
    super.key,
    required this.algorithmId,
  });

  @override
  State<GridVisualizerPage> createState() => _GridVisualizerPageState();
}

class _GridVisualizerPageState extends State<GridVisualizerPage> {
  GridInteractionMode _mode = GridInteractionMode.drawObstacle;

  @override
  void initState() {
    super.initState();
    context.read<GridBloc>().add(SelectAlgorithm(widget.algorithmId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GridBloc, GridState>(
      builder: (context, state) {
        if (state is GridInitial) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is GridReady) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.algorithm.name),
              centerTitle: AdaptiveLayout.isDesktop(context),
              actions: [
                IconButton(
                  icon: const Icon(Icons.compare_arrows),
                  onPressed: () => Navigator.pushNamed(context, Routes.graphComparison),
                  tooltip: 'Compare Algorithms',
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showAlgorithmInfo(context, state),
                  tooltip: 'Algorithm Info',
                ),
              ],
            ),
            body: _buildBody(context, state),
          );
        }

        if (state is GridError) {
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

  Widget _buildBody(BuildContext context, GridReady state) {
    final isDesktop = AdaptiveLayout.isDesktop(context);
    final isTablet = AdaptiveLayout.isTablet(context);

    if (isDesktop || isTablet) {
      return _buildWideLayout(context, state, isDesktop);
    }
    return _buildMobileLayout(context, state);
  }

  Widget _buildWideLayout(BuildContext context, GridReady state, bool isDesktop) {
    final spacing = AdaptiveLayout.getSpacing(context);

    return ConstrainedContent(
      maxWidth: isDesktop ? 1800 : 1400,
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel - Graph View & Legend
            SizedBox(
              width: isDesktop ? 280 : 220,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Graph View
                    GridGraphView(
                      grid: state.grid,
                      frame: state.currentFrame,
                      maxSize: isDesktop ? 260 : 200,
                    ),
                    SizedBox(height: spacing),

                    // Legend
                    const GridLegend(),
                    SizedBox(height: spacing),

                    // Stats Panel
                    GridStatsPanel(
                      grid: state.grid,
                      frame: state.currentFrame,
                      currentStep: state.currentStep,
                      totalSteps: state.frames.length,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: spacing),

            // Center - Grid Visualizer
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Grid
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: GridVisualizer(
                        grid: state.grid,
                        frame: state.currentFrame,
                        mode: _mode,
                        onCellTap: (x, y) => _handleCellTap(context, x, y, state),
                        onCellDrag: (x, y) => _handleCellDrag(context, x, y, state),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),

                  // Progress Slider
                  if (state.hasRun && state.frames.isNotEmpty) ...[
                    _buildProgressSlider(context, state),
                    SizedBox(height: spacing),
                  ],

                  // Playback Controls
                  if (state.hasRun && state.frames.isNotEmpty)
                    PlaybackControls(
                      isPlaying: state.isPlaying,
                      canStepBack: state.canStepBack,
                      canStepForward: state.canStepForward,
                      onPlayPause: () => _togglePlayPause(context, state),
                      onStepBack: () => context.read<GridBloc>().add(StepBackward()),
                      onStepForward: () => context.read<GridBloc>().add(StepForward()),
                      onReset: () => context.read<GridBloc>().add(ResetVisualization()),
                      onSkipToEnd: () => context.read<GridBloc>().add(SetStep(state.frames.length - 1)),
                    ),
                ],
              ),
            ),
            SizedBox(width: spacing),

            // Right Panel - Controls
            SizedBox(
              width: isDesktop ? 340 : 300,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Grid Controls
                    GridControls(
                      gridWidth: state.grid.width,
                      gridHeight: state.grid.height,
                      mode: _mode,
                      canRun: state.canRun,
                      hasRun: state.hasRun,
                      isPlaying: state.isPlaying,
                      onSizeChanged: (w, h) =>
                          context.read<GridBloc>().add(InitializeGrid(width: w, height: h)),
                      onModeChanged: (mode) => setState(() => _mode = mode),
                      onClear: () => context.read<GridBloc>().add(ClearGrid()),
                      onClearPath: () => context.read<GridBloc>().add(ClearVisualization()),
                      onRun: () => context.read<GridBloc>().add(RunAlgorithm()),
                    ),
                    SizedBox(height: spacing),

                    // Speed Control
                    SpeedSlider(
                      speed: state.speed,
                      onSpeedChanged: (speed) =>
                          context.read<GridBloc>().add(SetSpeed(speed)),
                    ),
                    SizedBox(height: spacing),

                    // Algorithm Info Panel
                    _buildInfoPanel(context, state),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, GridReady state) {
    final spacing = AdaptiveLayout.getSpacing(context);
    final padding = AdaptiveLayout.getAdaptivePadding(context);

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        children: [
          // Grid
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              child: GridVisualizer(
                grid: state.grid,
                frame: state.currentFrame,
                mode: _mode,
                onCellTap: (x, y) => _handleCellTap(context, x, y, state),
                onCellDrag: (x, y) => _handleCellDrag(context, x, y, state),
              ),
            ),
          ),
          SizedBox(height: spacing),

          // Legend (compact for mobile)
          const GridLegend(compact: true),
          SizedBox(height: spacing),

          // Grid Controls
          GridControls(
            gridWidth: state.grid.width,
            gridHeight: state.grid.height,
            mode: _mode,
            canRun: state.canRun,
            hasRun: state.hasRun,
            isPlaying: state.isPlaying,
            onSizeChanged: (w, h) =>
                context.read<GridBloc>().add(InitializeGrid(width: w, height: h)),
            onModeChanged: (mode) => setState(() => _mode = mode),
            onClear: () => context.read<GridBloc>().add(ClearGrid()),
            onClearPath: () => context.read<GridBloc>().add(ClearVisualization()),
            onRun: () => context.read<GridBloc>().add(RunAlgorithm()),
          ),
          SizedBox(height: spacing),

          // Progress Slider
          if (state.hasRun && state.frames.isNotEmpty) ...[
            _buildProgressSlider(context, state),
            SizedBox(height: spacing),
          ],

          // Playback Controls
          if (state.hasRun && state.frames.isNotEmpty) ...[
            PlaybackControls(
              isPlaying: state.isPlaying,
              canStepBack: state.canStepBack,
              canStepForward: state.canStepForward,
              onPlayPause: () => _togglePlayPause(context, state),
              onStepBack: () => context.read<GridBloc>().add(StepBackward()),
              onStepForward: () => context.read<GridBloc>().add(StepForward()),
              onReset: () => context.read<GridBloc>().add(ResetVisualization()),
              onSkipToEnd: () => context.read<GridBloc>().add(SetStep(state.frames.length - 1)),
            ),
            SizedBox(height: spacing),
          ],

          // Speed Control
          SpeedSlider(
            speed: state.speed,
            onSpeedChanged: (speed) => context.read<GridBloc>().add(SetSpeed(speed)),
          ),
          SizedBox(height: spacing),

          // Stats Panel
          GridStatsPanel(
            grid: state.grid,
            frame: state.currentFrame,
            currentStep: state.currentStep,
            totalSteps: state.frames.length,
          ),
          SizedBox(height: spacing),

          // Graph View (smaller for mobile)
          GridGraphView(
            grid: state.grid,
            frame: state.currentFrame,
            maxSize: 200,
          ),
          SizedBox(height: spacing),

          // Info Panel
          _buildInfoPanel(context, state),
          SizedBox(height: spacing),
        ],
      ),
    );
  }

  Widget _buildProgressSlider(BuildContext context, GridReady state) {
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
                '${state.frames.length} total',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Slider(
            value: state.currentStep.toDouble(),
            min: 0,
            max: (state.frames.length - 1).toDouble(),
            divisions: state.frames.length > 1 ? state.frames.length - 1 : 1,
            onChanged: (value) {
              context.read<GridBloc>().add(SetStep(value.toInt()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(BuildContext context, GridReady state) {
    final colorScheme = Theme.of(context).colorScheme;
    final frame = state.currentFrame;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.algorithm.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.algorithm.description,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildComplexityChip('Time', state.algorithm.timeComplexity, Colors.orange),
              const SizedBox(width: 8),
              _buildComplexityChip('Space', state.algorithm.spaceComplexity, colorScheme.primary),
            ],
          ),
          if (frame != null) ...[
            const Divider(height: 24),
            Text(
              frame.operation,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              frame.explanation,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComplexityChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 11, color: color),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  void _handleCellTap(BuildContext context, int x, int y, GridReady state) {
    switch (_mode) {
      case GridInteractionMode.drawObstacle:
        context.read<GridBloc>().add(ToggleObstacle(x, y));
        break;
      case GridInteractionMode.eraseObstacle:
        context.read<GridBloc>().add(RemoveObstacle(x, y));
        break;
      case GridInteractionMode.setStart:
        context.read<GridBloc>().add(SetGridStart(x, y));
        break;
      case GridInteractionMode.setEnd:
        context.read<GridBloc>().add(SetGridEnd(x, y));
        break;
    }
  }

  void _handleCellDrag(BuildContext context, int x, int y, GridReady state) {
    switch (_mode) {
      case GridInteractionMode.drawObstacle:
        context.read<GridBloc>().add(AddObstacle(x, y));
        break;
      case GridInteractionMode.eraseObstacle:
        context.read<GridBloc>().add(RemoveObstacle(x, y));
        break;
      default:
        // Don't handle drag for start/end setting
        break;
    }
  }

  void _togglePlayPause(BuildContext context, GridReady state) {
    if (state.isPlaying) {
      context.read<GridBloc>().add(PauseVisualization());
    } else {
      context.read<GridBloc>().add(PlayVisualization());
    }
  }

  void _showAlgorithmInfo(BuildContext context, GridReady state) {
    final algorithm = state.algorithm;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    algorithm.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    algorithm.description,
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Complexity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildComplexityRow('Time', algorithm.timeComplexity, Colors.orange),
                  _buildComplexityRow('Space', algorithm.spaceComplexity, colorScheme.primary),
                  const SizedBox(height: 24),
                  const Text(
                    'Pseudocode',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      algorithm.pseudocode.join('\n'),
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildComplexityRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
