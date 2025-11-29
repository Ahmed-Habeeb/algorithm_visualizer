import '../entities/recursion_tree_node_entity.dart';
import '../entities/recursion_frame_entity.dart';

abstract class RecursionAlgorithm {
  String get name;
  String get description;

  RecursionTreeNodeEntity buildTree(int input);
  List<RecursionFrameEntity> generateFrames(RecursionTreeNodeEntity tree);
}
