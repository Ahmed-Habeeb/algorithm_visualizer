import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/adaptive_layout.dart';
import '../../../../core/widgets/playback_controls.dart';
import '../../../../core/widgets/speed_slider.dart';
import '../bloc/ds_bloc.dart';
import '../bloc/ds_event.dart';
import '../bloc/ds_state.dart';
import '../widgets/ds_controls.dart';
import '../widgets/ds_info_panel.dart';
import '../widgets/ds_visualizer.dart';

class DSVisualizerPage extends StatefulWidget {
  final String structureId;

  const DSVisualizerPage({
    super.key,
    required this.structureId,
  });

  @override
  State<DSVisualizerPage> createState() => _DSVisualizerPageState();
}

class _DSVisualizerPageState extends State<DSVisualizerPage> {
  @override
  void initState() {
    super.initState();
    context.read<DSBloc>().add(SelectDataStructure(widget.structureId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DSBloc, DSState>(
      builder: (context, state) {
        if (state is DSLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DSReady) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.structure.name),
              centerTitle: AdaptiveLayout.isDesktop(context),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showStructureInfo(context, state),
                  tooltip: 'Structure Info',
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

  Widget _buildBody(BuildContext context, DSReady state) {
    return AdaptiveLayoutBuilder(
      mobile: _buildMobileLayout(context, state),
      tablet: _buildTabletLayout(context, state),
      desktop: _buildDesktopLayout(context, state),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DSReady state) {
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
                // Visualizer
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: state.currentFrame != null
                        ? DSVisualizer(
                            frame: state.currentFrame!,
                            structureId: state.structure.id,
                          )
                        : const Center(child: Text('No visualization')),
                  ),
                ),
                SizedBox(height: spacing),

                // Progress Slider
                if (state.frames.length > 1) ...[
                  _buildProgressSlider(context, state),
                  SizedBox(height: spacing),
                ],

                // Playback Controls
                if (state.frames.length > 1)
                  PlaybackControls(
                    isPlaying: state.isPlaying,
                    canStepBack: state.canStepBack,
                    canStepForward: state.canStepForward,
                    onPlayPause: () => _togglePlayPause(context, state),
                    onStepBack: () => context.read<DSBloc>().add(StepBackward()),
                    onStepForward: () => context.read<DSBloc>().add(StepForward()),
                    onReset: () => context.read<DSBloc>().add(ResetVisualization()),
                    onSkipToEnd: () => context.read<DSBloc>().add(SetStep(state.frames.length - 1)),
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
                // Controls
                DSControls(
                  structureId: state.structure.id,
                  onInsert: (value) => context.read<DSBloc>().add(InsertValue(value)),
                  onDelete: (value) => context.read<DSBloc>().add(DeleteValue(value)),
                  onSearch: (value) => context.read<DSBloc>().add(SearchValue(value)),
                  onRandomize: () => context.read<DSBloc>().add(RandomizeData()),
                  onClear: () => context.read<DSBloc>().add(ClearData()),
                ),
                SizedBox(height: spacing),

                // Speed Control
                SpeedSlider(
                  speed: state.speed,
                  onSpeedChanged: (speed) => context.read<DSBloc>().add(SetSpeed(speed)),
                ),
                SizedBox(height: spacing),

                // Info Panel
                Expanded(
                  child: SingleChildScrollView(
                    child: DSInfoPanel(
                      structureName: state.structure.name,
                      description: state.structure.description,
                      timeComplexities: state.structure.timeComplexities,
                      spaceComplexity: state.structure.spaceComplexity,
                      currentFrame: state.currentFrame,
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

  Widget _buildTabletLayout(BuildContext context, DSReady state) {
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
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: state.currentFrame != null
                        ? DSVisualizer(
                            frame: state.currentFrame!,
                            structureId: state.structure.id,
                          )
                        : const Center(child: Text('No visualization')),
                  ),
                ),
                SizedBox(height: spacing),
                if (state.frames.length > 1) ...[
                  _buildProgressSlider(context, state),
                  SizedBox(height: spacing),
                  PlaybackControls(
                    isPlaying: state.isPlaying,
                    canStepBack: state.canStepBack,
                    canStepForward: state.canStepForward,
                    onPlayPause: () => _togglePlayPause(context, state),
                    onStepBack: () => context.read<DSBloc>().add(StepBackward()),
                    onStepForward: () => context.read<DSBloc>().add(StepForward()),
                    onReset: () => context.read<DSBloc>().add(ResetVisualization()),
                    onSkipToEnd: () => context.read<DSBloc>().add(SetStep(state.frames.length - 1)),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: spacing),

          // Control Panel
          SizedBox(
            width: 320,
            child: Column(
              children: [
                DSControls(
                  structureId: state.structure.id,
                  onInsert: (value) => context.read<DSBloc>().add(InsertValue(value)),
                  onDelete: (value) => context.read<DSBloc>().add(DeleteValue(value)),
                  onSearch: (value) => context.read<DSBloc>().add(SearchValue(value)),
                  onRandomize: () => context.read<DSBloc>().add(RandomizeData()),
                  onClear: () => context.read<DSBloc>().add(ClearData()),
                ),
                SizedBox(height: spacing),
                SpeedSlider(
                  speed: state.speed,
                  onSpeedChanged: (speed) => context.read<DSBloc>().add(SetSpeed(speed)),
                ),
                SizedBox(height: spacing),
                Expanded(
                  child: SingleChildScrollView(
                    child: DSInfoPanel(
                      structureName: state.structure.name,
                      description: state.structure.description,
                      timeComplexities: state.structure.timeComplexities,
                      spaceComplexity: state.structure.spaceComplexity,
                      currentFrame: state.currentFrame,
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

  Widget _buildMobileLayout(BuildContext context, DSReady state) {
    final spacing = AdaptiveLayout.getSpacing(context);
    final padding = AdaptiveLayout.getAdaptivePadding(context);

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        children: [
          // Visualizer
          AspectRatio(
            aspectRatio: 1.2,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: state.currentFrame != null
                  ? DSVisualizer(
                      frame: state.currentFrame!,
                      structureId: state.structure.id,
                    )
                  : const Center(child: Text('No visualization')),
            ),
          ),
          SizedBox(height: spacing),

          // Controls
          DSControls(
            structureId: state.structure.id,
            onInsert: (value) => context.read<DSBloc>().add(InsertValue(value)),
            onDelete: (value) => context.read<DSBloc>().add(DeleteValue(value)),
            onSearch: (value) => context.read<DSBloc>().add(SearchValue(value)),
            onRandomize: () => context.read<DSBloc>().add(RandomizeData()),
            onClear: () => context.read<DSBloc>().add(ClearData()),
          ),
          SizedBox(height: spacing),

          // Progress Slider
          if (state.frames.length > 1) ...[
            _buildProgressSlider(context, state),
            SizedBox(height: spacing),
            PlaybackControls(
              isPlaying: state.isPlaying,
              canStepBack: state.canStepBack,
              canStepForward: state.canStepForward,
              onPlayPause: () => _togglePlayPause(context, state),
              onStepBack: () => context.read<DSBloc>().add(StepBackward()),
              onStepForward: () => context.read<DSBloc>().add(StepForward()),
              onReset: () => context.read<DSBloc>().add(ResetVisualization()),
              onSkipToEnd: () => context.read<DSBloc>().add(SetStep(state.frames.length - 1)),
            ),
            SizedBox(height: spacing),
          ],

          // Speed Control
          SpeedSlider(
            speed: state.speed,
            onSpeedChanged: (speed) => context.read<DSBloc>().add(SetSpeed(speed)),
          ),
          SizedBox(height: spacing),

          // Info Panel
          DSInfoPanel(
            structureName: state.structure.name,
            description: state.structure.description,
            timeComplexities: state.structure.timeComplexities,
            spaceComplexity: state.structure.spaceComplexity,
            currentFrame: state.currentFrame,
            stepNumber: state.currentStep + 1,
            totalSteps: state.frames.length,
          ),
          SizedBox(height: spacing),
        ],
      ),
    );
  }

  Widget _buildProgressSlider(BuildContext context, DSReady state) {
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
              context.read<DSBloc>().add(SetStep(value.toInt()));
            },
          ),
        ],
      ),
    );
  }

  void _togglePlayPause(BuildContext context, DSReady state) {
    if (state.isPlaying) {
      context.read<DSBloc>().add(PauseVisualization());
    } else {
      context.read<DSBloc>().add(PlayVisualization());
    }
  }

  void _showStructureInfo(BuildContext context, DSReady state) {
    final structure = state.structure;
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
                    structure.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    structure.description,
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Time Complexity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...structure.timeComplexities.entries.map(
                    (e) => _buildComplexityRow(e.key, e.value, Colors.orange),
                  ),
                  const SizedBox(height: 16),
                  _buildComplexityRow('Space', structure.spaceComplexity, colorScheme.primary),
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
                      structure.pseudocode.join('\n'),
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
