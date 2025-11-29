import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/adaptive_layout.dart';
import '../../../../core/widgets/playback_controls.dart';
import '../../../../core/widgets/speed_slider.dart';
import '../../domain/entities/dp_algorithm_entity.dart';
import '../../domain/entities/dp_frame_entity.dart';
import '../bloc/dp_bloc.dart';
import '../bloc/dp_event.dart';
import '../bloc/dp_state.dart';
import '../widgets/dp_table_visualizer.dart';
import '../widgets/dp_info_panel.dart';

class DPVisualizerPage extends StatefulWidget {
  final String algorithmId;

  const DPVisualizerPage({
    super.key,
    required this.algorithmId,
  });

  @override
  State<DPVisualizerPage> createState() => _DPVisualizerPageState();
}

class _DPVisualizerPageState extends State<DPVisualizerPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<DPBloc>();
    bloc.add(LoadAlgorithms());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DPBloc, DPState>(
      listener: (context, state) {
        if (state is DPReady && state.selectedAlgorithm == null) {
          context.read<DPBloc>().add(SelectAlgorithm(widget.algorithmId));
        }
      },
      builder: (context, state) {
        if (state is DPInitial || state is DPLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Dynamic Programming')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DPReady) {
          return _buildContent(context, state);
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Dynamic Programming')),
          body: const Center(child: Text('Something went wrong')),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, DPReady state) {
    final algorithm = state.selectedAlgorithm;

    return Scaffold(
      appBar: AppBar(
        title: Text(algorithm?.name ?? 'Dynamic Programming'),
      ),
      body: AdaptiveLayoutBuilder(
        mobile: _buildMobileLayout(context, state),
        tablet: _buildTabletLayout(context, state),
        desktop: _buildDesktopLayout(context, state),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DPReady state) {
    return Column(
      children: [
        // Controls
        _buildControlsPanel(context, state),

        // Visualization
        Expanded(
          flex: 3,
          child: _buildVisualization(context, state),
        ),

        // Info Panel
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: _buildInfoPanel(context, state),
          ),
        ),

        // Playback Controls
        _buildPlaybackControls(context, state),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, DPReady state) {
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
                child: _buildVisualization(context, state),
              ),

              // Info Panel
              SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  child: _buildInfoPanel(context, state),
                ),
              ),
            ],
          ),
        ),

        // Playback Controls
        _buildPlaybackControls(context, state),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DPReady state) {
    return Row(
      children: [
        // Left sidebar - Controls and Info
        SizedBox(
          width: 350,
          child: Column(
            children: [
              _buildControlsPanel(context, state),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildInfoPanel(context, state),
                ),
              ),
              _buildPlaybackControls(context, state),
            ],
          ),
        ),

        // Main content - Table Visualization
        Expanded(
          child: _buildVisualization(context, state),
        ),
      ],
    );
  }

  Widget _buildControlsPanel(BuildContext context, DPReady state) {
    final colorScheme = Theme.of(context).colorScheme;
    final algorithm = state.selectedAlgorithm;

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
          // Input controls based on algorithm type
          _buildInputControls(context, state, algorithm),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.frames.isEmpty
                      ? () {
                          context.read<DPBloc>().add(RunAlgorithm());
                        }
                      : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.frames.isNotEmpty
                      ? () {
                          context.read<DPBloc>().add(ResetVisualization());
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

  Widget _buildInputControls(BuildContext context, DPReady state, DPAlgorithmEntity? algorithm) {
    if (algorithm == null) return const SizedBox.shrink();

    switch (algorithm.type) {
      case DPAlgorithmType.fibonacci:
        return _buildFibonacciInput(context, state);
      case DPAlgorithmType.longestCommonSubsequence:
        return _buildLCSInput(context, state);
      case DPAlgorithmType.knapsack:
        return _buildKnapsackInput(context, state);
      case DPAlgorithmType.editDistance:
        return _buildEditDistanceInput(context, state);
    }
  }

  Widget _buildFibonacciInput(BuildContext context, DPReady state) {
    final n = state.input['n'] as int? ?? 8;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          'n =',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$n',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Slider(
            value: n.toDouble(),
            min: 2,
            max: 15,
            divisions: 13,
            label: '$n',
            onChanged: state.frames.isEmpty
                ? (value) {
                    context.read<DPBloc>().add(SetInput({'n': value.toInt()}));
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLCSInput(BuildContext context, DPReady state) {
    final str1 = state.input['str1'] as String? ?? 'ABCD';
    final str2 = state.input['str2'] as String? ?? 'AEBD';

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'String 1',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          controller: TextEditingController(text: str1),
          enabled: state.frames.isEmpty,
          onChanged: (value) {
            context.read<DPBloc>().add(SetInput({
              'str1': value.toUpperCase(),
              'str2': str2,
            }));
          },
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            labelText: 'String 2',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          controller: TextEditingController(text: str2),
          enabled: state.frames.isEmpty,
          onChanged: (value) {
            context.read<DPBloc>().add(SetInput({
              'str1': str1,
              'str2': value.toUpperCase(),
            }));
          },
        ),
      ],
    );
  }

  Widget _buildKnapsackInput(BuildContext context, DPReady state) {
    final capacity = state.input['capacity'] as int? ?? 8;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Capacity:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$capacity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Slider(
                value: capacity.toDouble(),
                min: 5,
                max: 15,
                divisions: 10,
                label: '$capacity',
                onChanged: state.frames.isEmpty
                    ? (value) {
                        context.read<DPBloc>().add(SetInput({
                          ...state.input,
                          'capacity': value.toInt(),
                        }));
                      }
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Items: A(w:2,v:3) B(w:3,v:4) C(w:4,v:5) D(w:5,v:6)',
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEditDistanceInput(BuildContext context, DPReady state) {
    final str1 = state.input['str1'] as String? ?? 'CAT';
    final str2 = state.input['str2'] as String? ?? 'CUT';

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Source String',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          controller: TextEditingController(text: str1),
          enabled: state.frames.isEmpty,
          onChanged: (value) {
            context.read<DPBloc>().add(SetInput({
              'str1': value.toUpperCase(),
              'str2': str2,
            }));
          },
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Target String',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          controller: TextEditingController(text: str2),
          enabled: state.frames.isEmpty,
          onChanged: (value) {
            context.read<DPBloc>().add(SetInput({
              'str1': str1,
              'str2': value.toUpperCase(),
            }));
          },
        ),
      ],
    );
  }

  Widget _buildVisualization(BuildContext context, DPReady state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.currentFrame == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grid_on,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Click "Run" to start visualization',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    // Generate row and column labels based on algorithm
    List<String>? rowLabels;
    List<String>? colLabels;

    final algorithm = state.selectedAlgorithm;
    if (algorithm != null) {
      switch (algorithm.type) {
        case DPAlgorithmType.fibonacci:
          colLabels = List.generate(
            state.currentFrame!.table[0].length,
            (i) => '$i',
          );
          break;
        case DPAlgorithmType.longestCommonSubsequence:
        case DPAlgorithmType.editDistance:
          final str1 = state.input['str1'] as String? ?? '';
          final str2 = state.input['str2'] as String? ?? '';
          rowLabels = ['', ...str1.split('')];
          colLabels = ['', ...str2.split('')];
          break;
        case DPAlgorithmType.knapsack:
          final items = state.input['items'] as List<KnapsackItem>? ?? [];
          rowLabels = ['', ...items.map((i) => i.name)];
          colLabels = List.generate(
            state.currentFrame!.table[0].length,
            (i) => '$i',
          );
          break;
      }
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
        child: DPTableVisualizer(
          frame: state.currentFrame!,
          rowLabels: rowLabels,
          colLabels: colLabels,
        ),
      ),
    );
  }

  Widget _buildInfoPanel(BuildContext context, DPReady state) {
    final frame = state.currentFrame;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: DPInfoPanel(
        algorithm: state.selectedAlgorithm,
        currentStep: frame?.operation ?? 'Ready',
        explanation: frame?.explanation ?? 'Configure inputs and click Run to visualize',
        formula: frame?.formula,
        stepNumber: state.frames.isEmpty ? 0 : state.currentFrameIndex + 1,
        totalSteps: state.frames.length,
      ),
    );
  }

  Widget _buildPlaybackControls(BuildContext context, DPReady state) {
    final bloc = context.read<DPBloc>();

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
