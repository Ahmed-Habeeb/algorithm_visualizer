sealed class DPEvent {}

class LoadAlgorithms extends DPEvent {}

class SelectAlgorithm extends DPEvent {
  final String algorithmId;
  SelectAlgorithm(this.algorithmId);
}

class SetInput extends DPEvent {
  final Map<String, dynamic> input;
  SetInput(this.input);
}

class RunAlgorithm extends DPEvent {}

class StartVisualization extends DPEvent {}

class PauseVisualization extends DPEvent {}

class ResumeVisualization extends DPEvent {}

class StopVisualization extends DPEvent {}

class StepForward extends DPEvent {}

class StepBackward extends DPEvent {}

class SetSpeed extends DPEvent {
  final double speed;
  SetSpeed(this.speed);
}

class GoToFrame extends DPEvent {
  final int frameIndex;
  GoToFrame(this.frameIndex);
}

class ResetVisualization extends DPEvent {}
