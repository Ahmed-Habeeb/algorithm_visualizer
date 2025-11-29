import 'package:flutter/foundation.dart';

@immutable
sealed class SearchingEvent {}

class LoadSearchingAlgorithms extends SearchingEvent {}

class SelectAlgorithm extends SearchingEvent {
  final String algorithmId;
  SelectAlgorithm(this.algorithmId);
}

class RunSearch extends SearchingEvent {
  final List<int> input;
  final int target;
  RunSearch({required this.input, required this.target});
}

class PlayVisualization extends SearchingEvent {}

class PauseVisualization extends SearchingEvent {}

class StepForward extends SearchingEvent {}

class StepBackward extends SearchingEvent {}

class SetSpeed extends SearchingEvent {
  final double speed;
  SetSpeed(this.speed);
}

class RandomizeInput extends SearchingEvent {
  final int size;
  RandomizeInput({this.size = 15});
}

class SetTarget extends SearchingEvent {
  final int target;
  SetTarget(this.target);
}

class ResetVisualization extends SearchingEvent {}
