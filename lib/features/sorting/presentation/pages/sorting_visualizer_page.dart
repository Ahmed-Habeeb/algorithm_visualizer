import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/adaptive_layout.dart';
import '../../../../core/widgets/array_size_slider.dart';
import '../../../../core/widgets/playback_controls.dart';
import '../../../../core/widgets/speed_slider.dart';
import '../../../../core/widgets/info_panel.dart';
import '../bloc/sorting_bloc.dart';
import '../bloc/sorting_event.dart';
import '../bloc/sorting_state.dart';
import '../widgets/array_visualizer.dart';

class SortingVisualizerPage extends StatefulWidget {
  final String algorithmId;

  const SortingVisualizerPage({
    super.key,
    required this.algorithmId,
  });

  @override
  State<SortingVisualizerPage> createState() => _SortingVisualizerPageState();
}

class _SortingVisualizerPageState extends State<SortingVisualizerPage> {
  int _arraySize = 20;

  @override
  void initState() {
    super.initState();
    context.read<SortingBloc>().add(SelectAlgorithm(widget.algorithmId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SortingBloc, SortingState>(
      builder: (context, state) {
        if (state is SortingLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is SortingVisualizationReady) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.algorithm.name),
              centerTitle: AdaptiveLayout.isDesktop(context),
              actions: [
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

        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('Something went wrong')),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SortingVisualizationReady state) {
    return AdaptiveLayoutBuilder(
      mobile: _buildMobileLayout(context, state),
      tablet: _buildTabletLayout(context, state),
      desktop: _buildDesktopLayout(context, state),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, SortingVisualizationReady state) {
    final spacing = AdaptiveLayout.getSpacing(context);

    return ConstrainedContent(
      maxWidth: 1800,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visualization Panel
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Array Visualizer
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: ArrayVisualizer(frame: state.currentFrame),
                  ),
                ),
                SizedBox(height: spacing),

                // Progress Slider
                _buildProgressSlider(context, state),
                SizedBox(height: spacing),

                // Playback Controls
                PlaybackControls(
                  isPlaying: state.isPlaying,
                  canStepBack: state.canStepBack,
                  canStepForward: state.canStepForward,
                  onPlayPause: () => _togglePlayPause(context, state),
                  onStepBack: () => context.read<SortingBloc>().add(StepBackward()),
                  onStepForward: () => context.read<SortingBloc>().add(StepForward()),
                  onReset: () => context.read<SortingBloc>().add(ResetVisualization()),
                  onSkipToEnd: () => context.read<SortingBloc>().add(SetStep(state.frames.length - 1)),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing),

          // Control Panel
          SizedBox(
            width: 400,
            child: Column(
              children: [
                // Array Size Control
                ArraySizeSlider(
                  size: _arraySize,
                  onSizeChanged: (size) => setState(() => _arraySize = size),
                  onRandomize: () => context.read<SortingBloc>().add(RandomizeInput(size: _arraySize)),
                ),
                SizedBox(height: spacing),

                // Speed Control
                SpeedSlider(
                  speed: state.speed,
                  onSpeedChanged: (speed) => context.read<SortingBloc>().add(SetSpeed(speed)),
                ),
                SizedBox(height: spacing),

                // Info Panel
                Expanded(
                  child: SingleChildScrollView(
                    child: InfoPanel(
                      algorithmName: state.algorithm.name,
                      description: state.algorithm.description,
                      timeComplexityBest: state.algorithm.timeComplexityBest,
                      timeComplexityAverage: state.algorithm.timeComplexityAverage,
                      timeComplexityWorst: state.algorithm.timeComplexityWorst,
                      spaceComplexity: state.algorithm.spaceComplexity,
                      currentStep: state.currentFrame.operation,
                      explanation: state.currentFrame.explanation,
                      stepNumber: state.currentStep + 1,
                      totalSteps: state.frames.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, SortingVisualizationReady state) {
    final spacing = AdaptiveLayout.getSpacing(context);

    return ConstrainedContent(
      maxWidth: 1200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visualization Panel
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Array Visualizer
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: ArrayVisualizer(frame: state.currentFrame),
                  ),
                ),
                SizedBox(height: spacing),

                // Progress Slider
                _buildProgressSlider(context, state),
                SizedBox(height: spacing),

                // Playback Controls
                PlaybackControls(
                  isPlaying: state.isPlaying,
                  canStepBack: state.canStepBack,
                  canStepForward: state.canStepForward,
                  onPlayPause: () => _togglePlayPause(context, state),
                  onStepBack: () => context.read<SortingBloc>().add(StepBackward()),
                  onStepForward: () => context.read<SortingBloc>().add(StepForward()),
                  onReset: () => context.read<SortingBloc>().add(ResetVisualization()),
                  onSkipToEnd: () => context.read<SortingBloc>().add(SetStep(state.frames.length - 1)),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing),

          // Control Panel
          SizedBox(
            width: 320,
            child: Column(
              children: [
                ArraySizeSlider(
                  size: _arraySize,
                  onSizeChanged: (size) => setState(() => _arraySize = size),
                  onRandomize: () => context.read<SortingBloc>().add(RandomizeInput(size: _arraySize)),
                ),
                SizedBox(height: spacing),
                SpeedSlider(
                  speed: state.speed,
                  onSpeedChanged: (speed) => context.read<SortingBloc>().add(SetSpeed(speed)),
                ),
                SizedBox(height: spacing),
                Expanded(
                  child: SingleChildScrollView(
                    child: InfoPanel(
                      algorithmName: state.algorithm.name,
                      description: state.algorithm.description,
                      timeComplexityBest: state.algorithm.timeComplexityBest,
                      timeComplexityAverage: state.algorithm.timeComplexityAverage,
                      timeComplexityWorst: state.algorithm.timeComplexityWorst,
                      spaceComplexity: state.algorithm.spaceComplexity,
                      currentStep: state.currentFrame.operation,
                      explanation: state.currentFrame.explanation,
                      stepNumber: state.currentStep + 1,
                      totalSteps: state.frames.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, SortingVisualizationReady state) {
    final spacing = AdaptiveLayout.getSpacing(context);
    final padding = AdaptiveLayout.getAdaptivePadding(context);

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        children: [
          // Array Visualizer
          AspectRatio(
            aspectRatio: 1.5,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: ArrayVisualizer(frame: state.currentFrame),
            ),
          ),
          SizedBox(height: spacing),

          // Array Size Control
          ArraySizeSlider(
            size: _arraySize,
            onSizeChanged: (size) => setState(() => _arraySize = size),
            onRandomize: () => context.read<SortingBloc>().add(RandomizeInput(size: _arraySize)),
          ),
          SizedBox(height: spacing),

          // Progress Slider
          _buildProgressSlider(context, state),
          SizedBox(height: spacing),

          // Playback Controls
          PlaybackControls(
            isPlaying: state.isPlaying,
            canStepBack: state.canStepBack,
            canStepForward: state.canStepForward,
            onPlayPause: () => _togglePlayPause(context, state),
            onStepBack: () => context.read<SortingBloc>().add(StepBackward()),
            onStepForward: () => context.read<SortingBloc>().add(StepForward()),
            onReset: () => context.read<SortingBloc>().add(ResetVisualization()),
            onSkipToEnd: () => context.read<SortingBloc>().add(SetStep(state.frames.length - 1)),
          ),
          SizedBox(height: spacing),

          // Speed Control
          SpeedSlider(
            speed: state.speed,
            onSpeedChanged: (speed) => context.read<SortingBloc>().add(SetSpeed(speed)),
          ),
          SizedBox(height: spacing),

          // Info Panel
          InfoPanel(
            algorithmName: state.algorithm.name,
            description: state.algorithm.description,
            timeComplexityBest: state.algorithm.timeComplexityBest,
            timeComplexityAverage: state.algorithm.timeComplexityAverage,
            timeComplexityWorst: state.algorithm.timeComplexityWorst,
            spaceComplexity: state.algorithm.spaceComplexity,
            currentStep: state.currentFrame.operation,
            explanation: state.currentFrame.explanation,
            stepNumber: state.currentStep + 1,
            totalSteps: state.frames.length,
          ),
          SizedBox(height: spacing),
        ],
      ),
    );
  }

  Widget _buildProgressSlider(BuildContext context, SortingVisualizationReady state) {
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
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${state.frames.length} total',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Slider(
            value: state.currentStep.toDouble(),
            min: 0,
            max: (state.frames.length - 1).toDouble(),
            divisions: state.frames.length > 1 ? state.frames.length - 1 : 1,
            onChanged: (value) {
              context.read<SortingBloc>().add(SetStep(value.toInt()));
            },
          ),
        ],
      ),
    );
  }

  void _togglePlayPause(BuildContext context, SortingVisualizationReady state) {
    if (state.isPlaying) {
      context.read<SortingBloc>().add(PauseVisualization());
    } else {
      context.read<SortingBloc>().add(PlayVisualization());
    }
  }

  void _showAlgorithmInfo(BuildContext context, SortingVisualizationReady state) {
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
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
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
                    'Time Complexity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildComplexityRow('Best', algorithm.timeComplexityBest, Colors.green),
                  _buildComplexityRow('Average', algorithm.timeComplexityAverage, Colors.orange),
                  _buildComplexityRow('Worst', algorithm.timeComplexityWorst, Colors.red),
                  const SizedBox(height: 16),
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
