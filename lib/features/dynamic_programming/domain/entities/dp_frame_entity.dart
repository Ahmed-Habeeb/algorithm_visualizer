import 'package:equatable/equatable.dart';

enum DPCellState {
  empty,
  computing,
  computed,
  highlighted,
  path,
}

class DPFrameEntity extends Equatable {
  final List<List<dynamic>> table;
  final Map<String, DPCellState> cellStates;
  final int? activeRow;
  final int? activeCol;
  final String operation;
  final String explanation;
  final String? formula;
  final List<(int, int)>? traceback;

  const DPFrameEntity({
    required this.table,
    this.cellStates = const {},
    this.activeRow,
    this.activeCol,
    required this.operation,
    required this.explanation,
    this.formula,
    this.traceback,
  });

  DPFrameEntity copyWith({
    List<List<dynamic>>? table,
    Map<String, DPCellState>? cellStates,
    int? activeRow,
    int? activeCol,
    String? operation,
    String? explanation,
    String? formula,
    List<(int, int)>? traceback,
  }) {
    return DPFrameEntity(
      table: table ?? this.table,
      cellStates: cellStates ?? this.cellStates,
      activeRow: activeRow ?? this.activeRow,
      activeCol: activeCol ?? this.activeCol,
      operation: operation ?? this.operation,
      explanation: explanation ?? this.explanation,
      formula: formula ?? this.formula,
      traceback: traceback ?? this.traceback,
    );
  }

  @override
  List<Object?> get props => [
        table,
        cellStates,
        activeRow,
        activeCol,
        operation,
        explanation,
        formula,
        traceback,
      ];
}

class KnapsackItem extends Equatable {
  final String name;
  final int weight;
  final int value;

  const KnapsackItem({
    required this.name,
    required this.weight,
    required this.value,
  });

  @override
  List<Object?> get props => [name, weight, value];
}
