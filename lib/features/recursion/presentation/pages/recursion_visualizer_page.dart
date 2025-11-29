import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/adaptive_layout.dart';
import '../../../../core/widgets/playback_controls.dart';
import '../../../../core/widgets/speed_slider.dart';
import '../../domain/entities/recursion_algorithm_entity.dart';
import '../bloc/recursion_bloc.dart';
import '../bloc/recursion_event.dart';
import '../bloc/recursion_state.dart';
import '../widgets/recursion_tree_visualizer.dart';
import '../widgets/call_stack_visualizer.dart';
import '../widgets/hanoi_visualizer.dart';
import '../widgets/recursion_info_panel.dart';

class RecursionVisualizerPage extends StatefulWidget {
  final String algorithmId;

  const RecursionVisualizerPage({
    super.key,
    required this.algorithmId,
  });

  @override
  State<RecursionVisualizerPage> createState() => _RecursionVisualizerPageState();
}

class _RecursionVisualizerPageState extends State<RecursionVisualizerPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<RecursionBloc>();
    bloc.add(LoadAlgorithms());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecursionBloc, RecursionState>(
      listener: (context, state) {
        if (state is RecursionReady && state.selectedAlgorithm == null) {
          context.read<RecursionBloc>().add(SelectAlgorithm(widget.algorithmId));
        }
      },
      builder: (context, state) {
        if (state is RecursionInitial || state is RecursionLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Recursion')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is RecursionReady) {
          return _buildContent(context, state);
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Recursion')),
          body: const Center(child: Text('Something went wrong')),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, RecursionReady state) {
    final algorithm = state.selectedAlgorithm;
    final isHanoi = algorithm?.type == RecursionAlgorithmType.towerOfHanoi;

    return Scaffold(
      appBar: AppBar(
        title: Text(algorithm?.name ?? 'Recursion'),
        actions: [
          if (state.result != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Result: ${state.result}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: AdaptiveLayoutBuilder(
        mobile: _buildMobileLayout(context, state, isHanoi),
        tablet: _buildTabletLayout(context, state, isHanoi),
        desktop: _buildDesktopLayout(context, state, isHanoi),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, RecursionReady state, bool isHanoi) {
    return Column(
      children: [
        // Controls
        _buildControlsPanel(context, state),

        // Visualization
        Expanded(
          flex: 3,
          child: _buildVisualization(context, state, isHanoi),
        ),

        // Call Stack
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CallStackVisualizer(
              callStack: state.currentFrame?.callStack ?? [],
              activeCall: state.currentFrame?.callStack.isNotEmpty == true
                  ? state.currentFrame!.callStack.last
                  : null,
            ),
          ),
        ),

        // Info Panel
        _buildInfoPanel(context, state),

        // Playback Controls
        _buildPlaybackControls(context, state),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, RecursionReady state, bool isHanoi) {
    return Column(
      children: [
        // Controls
        _buildControlsPanel(context, state),

        // Main content
        Expanded(
          child: Row(
            children: [
              // Visualization
              Expanded(
                flex: 2,
                child: _buildVisualization(context, state, isHanoi),
              ),

              // Call Stack
              SizedBox(
                width: 250,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CallStackVisualizer(
                    callStack: state.currentFrame?.callStack ?? [],
                    activeCall: state.currentFrame?.callStack.isNotEmpty == true
                        ? state.currentFrame!.callStack.last
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Info Panel
        _buildInfoPanel(context, state),

        // Playback Controls
        _buildPlaybackControls(context, state),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, RecursionReady state, bool isHanoi) {
    return Row(
      children: [
        // Left sidebar - Controls and Info
        SizedBox(
          width: 320,
          child: Column(
            children: [
              _buildControlsPanel(context, state),
              Expanded(child: _buildInfoPanel(context, state)),
              _buildPlaybackControls(context, state),
            ],
          ),
        ),

        // Main content
        Expanded(
          child: Column(
            children: [
              // Visualization
              Expanded(
                flex: 3,
                child: _buildVisualization(context, state, isHanoi),
              ),

              // Hanoi specific visualization
              if (isHanoi && state.currentFrame?.hanoiPegs != null)
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: HanoiVisualizer(
                      pegs: state.currentFrame!.hanoiPegs!,
                      totalDisks: state.input,
                      currentMove: state.currentFrame!.hanoiMoves?.isNotEmpty == true
                          ? state.currentFrame!.hanoiMoves!.last
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Right sidebar - Call Stack
        SizedBox(
          width: 280,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CallStackVisualizer(
              callStack: state.currentFrame?.callStack ?? [],
              activeCall: state.currentFrame?.callStack.isNotEmpty == true
                  ? state.currentFrame!.callStack.last
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsPanel(BuildContext context, RecursionReady state) {
    final colorScheme = Theme.of(context).colorScheme;
    final algorithm = state.selectedAlgorithm;
    final isHanoi = algorithm?.type == RecursionAlgorithmType.towerOfHanoi;

    // Input limits based on algorithm
    int minInput = 1;
    int maxInput = isHanoi ? 6 : 10;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input slider
          Row(
            children: [
              Text(
                isHanoi ? 'Disks:' : 'n =',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.input}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: state.input.toDouble(),
                  min: minInput.toDouble(),
                  max: maxInput.toDouble(),
                  divisions: maxInput - minInput,
                  label: '${state.input}',
                  onChanged: state.frames.isEmpty
                      ? (value) {
                          context.read<RecursionBloc>().add(SetInput(value.toInt()));
                        }
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.frames.isEmpty
                      ? () {
                          context.read<RecursionBloc>().add(BuildTree());
                        }
                      : null,
                  icon: const Icon(Icons.account_tree),
                  label: const Text('Build Tree'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.frames.isNotEmpty
                      ? () {
                          context.read<RecursionBloc>().add(ResetVisualization());
                        }
                      : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualization(BuildContext context, RecursionReady state, bool isHanoi) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.tree == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Click "Build Tree" to start',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: RecursionTreeVisualizer(
          tree: state.tree!,
          frame: state.currentFrame,
        ),
      ),
    );
  }

  Widget _buildInfoPanel(BuildContext context, RecursionReady state) {
    final frame = state.currentFrame;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: RecursionInfoPanel(
        algorithm: state.selectedAlgorithm,
        currentStep: frame?.operation ?? 'Ready',
        explanation: frame?.explanation ?? 'Build the recursion tree to visualize the algorithm',
        stepNumber: state.frames.isEmpty ? 0 : state.currentFrameIndex + 1,
        totalSteps: state.frames.length,
      ),
    );
  }

  Widget _buildPlaybackControls(BuildContext context, RecursionReady state) {
    final bloc = context.read<RecursionBloc>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        children: [
          SpeedSlider(
            speed: state.speed,
            onSpeedChanged: (speed) {
              bloc.add(SetSpeed(speed));
            },
          ),
          const SizedBox(height: 8),
          PlaybackControls(
            isPlaying: state.isPlaying,
            canStepBack: state.canStepBackward,
            canStepForward: state.canStepForward,
            onPlayPause: () {
              if (state.isPlaying) {
                bloc.add(PauseVisualization());
              } else if (state.frames.isNotEmpty && !state.isComplete) {
                bloc.add(StartVisualization());
              }
            },
            onStepBack: () {
              bloc.add(StepBackward());
            },
            onStepForward: () {
              bloc.add(StepForward());
            },
            onReset: () {
              bloc.add(StopVisualization());
            },
            onSkipToEnd: () {
              bloc.add(GoToFrame(state.frames.length - 1));
            },
          ),
        ],
      ),
    );
  }
}
