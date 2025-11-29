sealed class DSEvent {}

class SelectDataStructure extends DSEvent {
  final String structureId;
  SelectDataStructure(this.structureId);
}

class InsertValue extends DSEvent {
  final int value;
  InsertValue(this.value);
}

class DeleteValue extends DSEvent {
  final int value;
  DeleteValue(this.value);
}

class SearchValue extends DSEvent {
  final int value;
  SearchValue(this.value);
}

class RandomizeData extends DSEvent {
  final int count;
  RandomizeData({this.count = 7});
}

class ClearData extends DSEvent {}

class PlayVisualization extends DSEvent {}

class PauseVisualization extends DSEvent {}

class StepForward extends DSEvent {}

class StepBackward extends DSEvent {}

class SetStep extends DSEvent {
  final int step;
  SetStep(this.step);
}

class ResetVisualization extends DSEvent {}

class SetSpeed extends DSEvent {
  final double speed;
  SetSpeed(this.speed);
}

class TickAnimation extends DSEvent {}
