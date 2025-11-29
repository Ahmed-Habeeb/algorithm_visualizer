import '../entities/data_structure_entity.dart';
import '../entities/ds_visualization_frame_entity.dart';

abstract class DataStructure {
  DataStructureEntity get info;

  List<DSVisualizationFrameEntity> insert(List<int> currentData, int value);
  List<DSVisualizationFrameEntity> delete(List<int> currentData, int value);
  List<DSVisualizationFrameEntity> search(List<int> currentData, int value);
  List<DSVisualizationFrameEntity> visualize(List<int> data);
}
