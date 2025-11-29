import '../entities/dp_frame_entity.dart';

abstract class DPAlgorithm {
  String get name;
  String get description;

  List<DPFrameEntity> generateFrames(Map<String, dynamic> input);
}
