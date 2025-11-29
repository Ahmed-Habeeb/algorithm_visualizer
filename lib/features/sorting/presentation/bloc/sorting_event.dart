sealed class SortingEvent {}

class LoadSortingAlgorithms extends SortingEvent {}

class SelectAlgorithm extends SortingEvent {
  final String algorithmId;

  SelectAlgorithm(this.algorithmId);
}

class RunAlgorithm extends SortingEvent {
  final List<int> input;

  RunAlgorithm(this.input);
}

class PlayVisualization extends SortingEvent {}

class PauseVisualization extends SortingEvent {}

class StepForward extends SortingEvent {}

class StepBackward extends SortingEvent {}

class ResetVisualization extends SortingEvent {}

class SetSpeed extends SortingEvent {
  final double speed;

  SetSpeed(this.speed);
}

class SetStep extends SortingEvent {
  final int step;

  SetStep(this.step);
}

class RandomizeInput extends SortingEvent {
  final int size;

  RandomizeInput({this.size = 20});
}
