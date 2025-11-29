import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/adaptive_layout.dart';
import '../bloc/searching_bloc.dart';
import '../bloc/searching_event.dart';
import '../bloc/searching_state.dart';
import '../widgets/search_array_painter.dart';

class SearchingVisualizerPage extends StatefulWidget {
  final String algorithmId;

  const SearchingVisualizerPage({super.key, required this.algorithmId});

  @override
  State<SearchingVisualizerPage> createState() => _SearchingVisualizerPageState();
}

class _SearchingVisualizerPageState extends State<SearchingVisualizerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<SearchingBloc>();
      bloc.add(LoadSearchingAlgorithms());
      bloc.add(SelectAlgorithm(widget.algorithmId));
      bloc.add(RandomizeInput(size: 15));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<SearchingBloc, SearchingState>(
          builder: (context, state) {
            return Text(
              state.selectedAlgorithm != null
                  ? 'algorithms.${state.selectedAlgorithm!.id}'.tr()
                  : 'categories.searching'.tr(),
            );
          },
        ),
        centerTitle: AdaptiveLayout.isDesktop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAlgorithmInfo(context),
          ),
        ],
      ),
      body: BlocBuilder<SearchingBloc, SearchingState>(
        builder: (context, state) {
          return AdaptiveLayoutBuilder(
            mobile: _buildMobileLayout(context, state),
            tablet: _buildTabletLayout(context, state),
            desktop: _buildDesktopLayout(context, state),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, SearchingState state) {
    final colorScheme = Theme.of(context).colorScheme;
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
                // Visualization area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: state.currentFrame != null
                        ? SearchArrayVisualization(frame: state.currentFrame!)
                        : Center(
                            child: Text(
                              'Press Run to start visualization',
                              style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: spacing),

                // Status panel
                if (state.currentFrame != null) _buildStatusPanel(context, state),
                SizedBox(height: spacing),

                // Progress slider and controls
                _buildProgressSlider(context, state),
                SizedBox(height: spacing),
                _buildPlaybackControls(context, state),
              ],
            ),
          ),
          SizedBox(width: spacing),

          // Side panel
          SizedBox(
            width: 400,
            child: Column(
              children: [
                // Input controls
                _buildInputControls(context, state),
                SizedBox(height: spacing),

                // Target selection
                if (state.currentInput.isNotEmpty) _buildTargetSelection(context, state),
                SizedBox(height: spacing),

                // Speed control
                _buildSpeedControl(context, state),
                SizedBox(height: spacing),

                // Algorithm info card
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildAlgorithmInfoCard(context, state),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, SearchingState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = AdaptiveLayout.getSpacing(context);

    return ConstrainedContent(
      maxWidth: 1200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: state.currentFrame != null
                        ? SearchArrayVisualization(frame: state.currentFrame!)
                        : Center(child: Text('Press Run to start', style: TextStyle(color: colorScheme.onSurfaceVariant))),
                  ),
                ),
                SizedBox(height: spacing),
                if (state.currentFrame != null) _buildStatusPanel(context, state),
                SizedBox(height: spacing),
                _buildProgressSlider(context, state),
                SizedBox(height: spacing),
                _buildPlaybackControls(context, state),
              ],
            ),
          ),
          SizedBox(width: spacing),
          SizedBox(
            width: 320,
            child: Column(
              children: [
                _buildInputControls(context, state),
                SizedBox(height: spacing),
                if (state.currentInput.isNotEmpty) _buildTargetSelection(context, state),
                SizedBox(height: spacing),
                _buildSpeedControl(context, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, SearchingState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = AdaptiveLayout.getSpacing(context);
    final padding = AdaptiveLayout.getAdaptivePadding(context);

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        children: [
          // Visualization area
          AspectRatio(
            aspectRatio: 1.5,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              padding: const EdgeInsets.all(12),
              child: state.currentFrame != null
                  ? SearchArrayVisualization(frame: state.currentFrame!)
                  : Center(
                      child: Text(
                        'Press Run to start visualization',
                        style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                      ),
                    ),
            ),
          ),
          SizedBox(height: spacing),

          // Status panel
          if (state.currentFrame != null) _buildStatusPanel(context, state),
          SizedBox(height: spacing),

          // Input controls
          _buildInputControls(context, state),
          SizedBox(height: spacing),

          // Target selection
          if (state.currentInput.isNotEmpty) _buildTargetSelection(context, state),
          SizedBox(height: spacing),

          // Progress slider
          if (state.hasFrames) _buildProgressSlider(context, state),
          SizedBox(height: spacing),

          // Playback controls
          _buildPlaybackControls(context, state),
          SizedBox(height: spacing),

          // Speed control
          _buildSpeedControl(context, state),
          SizedBox(height: spacing),
        ],
      ),
    );
  }

  Widget _buildStatusPanel(BuildContext context, SearchingState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Operation: ${state.currentFrame!.operation}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
              Text(
                'Target: ${state.target}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.currentFrame!.explanation,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Frame ${state.currentFrameIndex + 1} of ${state.frames.length}',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildInputControls(BuildContext context, SearchingState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.read<SearchingBloc>().add(RandomizeInput(size: 15)),
            icon: const Icon(Icons.shuffle),
            label: Text('controls.randomize'.tr()),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.currentInput.isNotEmpty
                ? () => context.read<SearchingBloc>().add(RunSearch(input: state.currentInput, target: state.target))
                : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetSelection(BuildContext context, SearchingState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Target:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...state.currentInput.toSet().take(8).map((value) {
                final isSelected = value == state.target;
                return ChoiceChip(
                  label: Text(value.toString()),
                  selected: isSelected,
                  onSelected: (_) => context.read<SearchingBloc>().add(SetTarget(value)),
                );
              }),
              ChoiceChip(
                label: const Text('N/A'),
                selected: false,
                onSelected: (_) => context.read<SearchingBloc>().add(SetTarget(Random().nextInt(100) + 101)),
                tooltip: 'Value not in array',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSlider(BuildContext context, SearchingState state) {
    if (!state.hasFrames) return const SizedBox.shrink();

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
              Text('Step ${state.currentFrameIndex + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Text('${state.frames.length} total', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Slider(
            value: state.currentFrameIndex.toDouble(),
            min: 0,
            max: (state.frames.length - 1).toDouble(),
            divisions: state.frames.length > 1 ? state.frames.length - 1 : 1,
            onChanged: (value) {
              context.read<SearchingBloc>().add(PauseVisualization());
              final targetIndex = value.round();
              final currentIndex = state.currentFrameIndex;
              if (targetIndex > currentIndex) {
                for (int i = 0; i < targetIndex - currentIndex; i++) {
                  context.read<SearchingBloc>().add(StepForward());
                }
              } else if (targetIndex < currentIndex) {
                for (int i = 0; i < currentIndex - targetIndex; i++) {
                  context.read<SearchingBloc>().add(StepBackward());
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackControls(BuildContext context, SearchingState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: state.canStepBackward ? () => context.read<SearchingBloc>().add(StepBackward()) : null,
          icon: const Icon(Icons.skip_previous, size: 32),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          onPressed: state.hasFrames
              ? () {
                  if (state.isPlaying) {
                    context.read<SearchingBloc>().add(PauseVisualization());
                  } else {
                    context.read<SearchingBloc>().add(PlayVisualization());
                  }
                }
              : null,
          child: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: state.canStepForward ? () => context.read<SearchingBloc>().add(StepForward()) : null,
          icon: const Icon(Icons.skip_next, size: 32),
        ),
      ],
    );
  }

  Widget _buildSpeedControl(BuildContext context, SearchingState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text('controls.speed'.tr(), style: const TextStyle(fontSize: 14)),
          Expanded(
            child: Slider(
              value: state.speed,
              min: 0.25,
              max: 4.0,
              divisions: 15,
              label: '${state.speed}x',
              onChanged: (value) => context.read<SearchingBloc>().add(SetSpeed(value)),
            ),
          ),
          Text('${state.speed}x', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAlgorithmInfoCard(BuildContext context, SearchingState state) {
    if (state.selectedAlgorithm == null) return const SizedBox.shrink();

    final algorithm = state.selectedAlgorithm!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(algorithm.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(algorithm.description, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant)),
            const Divider(height: 24),
            _buildComplexityRow('Best', algorithm.timeComplexityBest, Colors.green),
            _buildComplexityRow('Average', algorithm.timeComplexityAverage, Colors.orange),
            _buildComplexityRow('Worst', algorithm.timeComplexityWorst, Colors.red),
            _buildComplexityRow('Space', algorithm.spaceComplexity, colorScheme.primary),
          ],
        ),
      ),
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
            child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  void _showAlgorithmInfo(BuildContext context) {
    final state = context.read<SearchingBloc>().state;
    if (state.selectedAlgorithm == null) return;

    final algorithm = state.selectedAlgorithm!;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                      decoration: BoxDecoration(color: colorScheme.outline, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('algorithms.${algorithm.id}'.tr(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(algorithm.description, style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  Text('complexity.time'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _buildComplexityRow('complexity.best'.tr(), algorithm.timeComplexityBest, Colors.green),
                  _buildComplexityRow('complexity.average'.tr(), algorithm.timeComplexityAverage, Colors.orange),
                  _buildComplexityRow('complexity.worst'.tr(), algorithm.timeComplexityWorst, Colors.red),
                  const SizedBox(height: 16),
                  _buildComplexityRow('complexity.space'.tr(), algorithm.spaceComplexity, colorScheme.primary),
                  const SizedBox(height: 24),
                  const Text('Pseudocode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(algorithm.pseudocode.join('\n'), style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
