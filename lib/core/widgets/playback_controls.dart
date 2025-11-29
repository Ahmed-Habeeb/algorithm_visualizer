import 'package:flutter/material.dart';

class PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final bool canStepBack;
  final bool canStepForward;
  final VoidCallback onPlayPause;
  final VoidCallback onStepBack;
  final VoidCallback onStepForward;
  final VoidCallback onReset;
  final VoidCallback onSkipToEnd;

  const PlaybackControls({
    super.key,
    required this.isPlaying,
    required this.canStepBack,
    required this.canStepForward,
    required this.onPlayPause,
    required this.onStepBack,
    required this.onStepForward,
    required this.onReset,
    required this.onSkipToEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          // Reset
          _ControlButton(
            icon: Icons.replay,
            onPressed: onReset,
            tooltip: 'Reset',
          ),

          // Step Back
          _ControlButton(
            icon: Icons.skip_previous,
            onPressed: canStepBack ? onStepBack : null,
            tooltip: 'Previous Step',
          ),

          // Play/Pause
          _PlayPauseButton(
            isPlaying: isPlaying,
            onPressed: onPlayPause,
          ),

          // Step Forward
          _ControlButton(
            icon: Icons.skip_next,
            onPressed: canStepForward ? onStepForward : null,
            tooltip: 'Next Step',
          ),

          // Skip to End
          _ControlButton(
            icon: Icons.last_page,
            onPressed: canStepForward ? onSkipToEnd : null,
            tooltip: 'Skip to End',
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 24),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          disabledForegroundColor: Colors.grey.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: isPlaying ? 'Pause' : 'Play',
      child: Material(
        color: theme.primaryColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
