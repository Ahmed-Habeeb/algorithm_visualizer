sealed class GraphEvent {}

/// Select which algorithm to use
class SelectAlgorithm extends GraphEvent {
  final String algorithmId;
  SelectAlgorithm(this.algorithmId);
}

/// Initialize or resize the grid
class InitializeGrid extends GraphEvent {
  final int width;
  final int height;
  InitializeGrid({this.width = 20, this.height = 20});
}

/// Toggle obstacle at a specific cell
class ToggleObstacle extends GraphEvent {
  final int x;
  final int y;
  ToggleObstacle(this.x, this.y);
}

/// Add obstacle at a specific cell (for drag drawing)
class AddObstacle extends GraphEvent {
  final int x;
  final int y;
  AddObstacle(this.x, this.y);
}

/// Remove obstacle at a specific cell (for drag erasing)
class RemoveObstacle extends GraphEvent {
  final int x;
  final int y;
  RemoveObstacle(this.x, this.y);
}

/// Set start point on grid
class SetGridStart extends GraphEvent {
  final int x;
  final int y;
  SetGridStart(this.x, this.y);
}

/// Set end point on grid
class SetGridEnd extends GraphEvent {
  final int x;
  final int y;
  SetGridEnd(this.x, this.y);
}

/// Clear all obstacles
class ClearObstacles extends GraphEvent {}

/// Clear everything (obstacles, start, end, visualization)
class ClearGrid extends GraphEvent {}

/// Clear only the visualization (keep obstacles, start, end)
class ClearVisualization extends GraphEvent {}

/// Run the selected algorithm
class RunAlgorithm extends GraphEvent {}

/// Start playing the visualization
class PlayVisualization extends GraphEvent {}

/// Pause the visualization
class PauseVisualization extends GraphEvent {}

/// Step forward one frame
class StepForward extends GraphEvent {}

/// Step backward one frame
class StepBackward extends GraphEvent {}

/// Jump to a specific step
class SetStep extends GraphEvent {
  final int step;
  SetStep(this.step);
}

/// Reset visualization to beginning
class ResetVisualization extends GraphEvent {}

/// Change animation speed
class SetSpeed extends GraphEvent {
  final double speed;
  SetSpeed(this.speed);
}

/// Internal tick event for animation
class TickAnimation extends GraphEvent {}
