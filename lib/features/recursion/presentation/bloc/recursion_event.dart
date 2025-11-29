sealed class RecursionEvent {}

class LoadAlgorithms extends RecursionEvent {}

class SelectAlgorithm extends RecursionEvent {
  final String algorithmId;
  SelectAlgorithm(this.algorithmId);
}

class SetInput extends RecursionEvent {
  final int input;
  SetInput(this.input);
}

class BuildTree extends RecursionEvent {}

class StartVisualization extends RecursionEvent {}

class PauseVisualization extends RecursionEvent {}

class ResumeVisualization extends RecursionEvent {}

class StopVisualization extends RecursionEvent {}

class StepForward extends RecursionEvent {}

class StepBackward extends RecursionEvent {}

class SetSpeed extends RecursionEvent {
  final double speed;
  SetSpeed(this.speed);
}

class GoToFrame extends RecursionEvent {
  final int frameIndex;
  GoToFrame(this.frameIndex);
}

class ResetVisualization extends RecursionEvent {}
