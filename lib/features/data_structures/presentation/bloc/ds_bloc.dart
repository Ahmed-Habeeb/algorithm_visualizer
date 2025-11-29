import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/structures/binary_search_tree.dart';
import '../../data/structures/linked_list_ds.dart';
import '../../data/structures/queue_ds.dart';
import '../../data/structures/stack_ds.dart';
import '../../domain/interfaces/data_structure.dart';
import 'ds_event.dart';
import 'ds_state.dart';

class DSBloc extends Bloc<DSEvent, DSState> {
  Timer? _animationTimer;

  final Map<String, DataStructure> _structureMap = {
    'stack': StackDS(),
    'queue': QueueDS(),
    'linked_list': LinkedListDS(),
    'bst': BinarySearchTree(),
  };

  DSBloc() : super(DSInitial()) {
    on<SelectDataStructure>(_onSelectDataStructure);
    on<InsertValue>(_onInsertValue);
    on<DeleteValue>(_onDeleteValue);
    on<SearchValue>(_onSearchValue);
    on<RandomizeData>(_onRandomizeData);
    on<ClearData>(_onClearData);
    on<PlayVisualization>(_onPlayVisualization);
    on<PauseVisualization>(_onPauseVisualization);
    on<StepForward>(_onStepForward);
    on<StepBackward>(_onStepBackward);
    on<SetStep>(_onSetStep);
    on<ResetVisualization>(_onResetVisualization);
    on<SetSpeed>(_onSetSpeed);
    on<TickAnimation>(_onTickAnimation);
  }

  @override
  Future<void> close() {
    _animationTimer?.cancel();
    return super.close();
  }

  void _onSelectDataStructure(SelectDataStructure event, Emitter<DSState> emit) {
    final structure = _structureMap[event.structureId];
    if (structure == null) {
      emit(DSError('Data structure not found: ${event.structureId}'));
      return;
    }

    // Generate initial data
    final random = math.Random();
    final initialData = List.generate(5, (_) => random.nextInt(99) + 1);

    final frames = structure.visualize(initialData);

    emit(DSReady(
      structure: structure.info,
      data: initialData,
      frames: frames,
    ));
  }

  void _onInsertValue(InsertValue event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;

    _animationTimer?.cancel();

    final structure = _structureMap[currentState.structure.id];
    if (structure == null) return;

    final frames = structure.insert(currentState.data, event.value);
    final newData = List<int>.from(currentState.data)..add(event.value);

    emit(currentState.copyWith(
      data: newData,
      frames: frames,
      currentStep: 0,
      isPlaying: false,
      lastOperation: 'insert',
    ));
  }

  void _onDeleteValue(DeleteValue event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;

    _animationTimer?.cancel();

    final structure = _structureMap[currentState.structure.id];
    if (structure == null) return;

    final frames = structure.delete(currentState.data, event.value);

    // Update data based on structure type
    List<int> newData;
    if (currentState.structure.id == 'stack') {
      // Stack pops from top
      newData = List<int>.from(currentState.data);
      if (newData.isNotEmpty) newData.removeLast();
    } else if (currentState.structure.id == 'queue') {
      // Queue dequeues from front
      newData = List<int>.from(currentState.data);
      if (newData.isNotEmpty) newData.removeAt(0);
    } else {
      // For others, remove the specific value
      newData = List<int>.from(currentState.data)..remove(event.value);
    }

    emit(currentState.copyWith(
      data: newData,
      frames: frames,
      currentStep: 0,
      isPlaying: false,
      lastOperation: 'delete',
    ));
  }

  void _onSearchValue(SearchValue event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;

    _animationTimer?.cancel();

    final structure = _structureMap[currentState.structure.id];
    if (structure == null) return;

    final frames = structure.search(currentState.data, event.value);

    emit(currentState.copyWith(
      frames: frames,
      currentStep: 0,
      isPlaying: false,
      lastOperation: 'search',
    ));
  }

  void _onRandomizeData(RandomizeData event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;

    _animationTimer?.cancel();

    final random = math.Random();
    final newData = List.generate(event.count, (_) => random.nextInt(99) + 1);

    final structure = _structureMap[currentState.structure.id];
    final frames = structure?.visualize(newData) ?? [];

    emit(currentState.copyWith(
      data: newData,
      frames: frames,
      currentStep: 0,
      isPlaying: false,
      lastOperation: null,
    ));
  }

  void _onClearData(ClearData event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;

    _animationTimer?.cancel();

    final structure = _structureMap[currentState.structure.id];
    final frames = structure?.visualize([]) ?? [];

    emit(currentState.copyWith(
      data: [],
      frames: frames,
      currentStep: 0,
      isPlaying: false,
      lastOperation: null,
    ));
  }

  void _onPlayVisualization(PlayVisualization event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;
    if (currentState.frames.isEmpty) return;

    _startAnimation(currentState.speed);
    emit(currentState.copyWith(isPlaying: true));
  }

  void _onPauseVisualization(PauseVisualization event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;

    _animationTimer?.cancel();
    emit(currentState.copyWith(isPlaying: false));
  }

  void _onStepForward(StepForward event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;

    if (currentState.canStepForward) {
      emit(currentState.copyWith(currentStep: currentState.currentStep + 1));
    }
  }

  void _onStepBackward(StepBackward event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;

    if (currentState.canStepBack) {
      emit(currentState.copyWith(currentStep: currentState.currentStep - 1));
    }
  }

  void _onSetStep(SetStep event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;

    if (event.step >= 0 && event.step < currentState.frames.length) {
      emit(currentState.copyWith(currentStep: event.step));
    }
  }

  void _onResetVisualization(ResetVisualization event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;

    _animationTimer?.cancel();
    emit(currentState.copyWith(
      currentStep: 0,
      isPlaying: false,
    ));
  }

  void _onSetSpeed(SetSpeed event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;

    emit(currentState.copyWith(speed: event.speed));

    if (currentState.isPlaying) {
      _animationTimer?.cancel();
      _startAnimation(event.speed);
    }
  }

  void _onTickAnimation(TickAnimation event, Emitter<DSState> emit) {
    final currentState = state;
    if (currentState is! DSReady) return;

    if (currentState.canStepForward) {
      emit(currentState.copyWith(currentStep: currentState.currentStep + 1));
    } else {
      _animationTimer?.cancel();
      emit(currentState.copyWith(isPlaying: false));
    }
  }

  void _startAnimation(double speed) {
    _animationTimer?.cancel();
    final duration = Duration(milliseconds: (800 / speed).round());
    _animationTimer = Timer.periodic(duration, (_) {
      add(TickAnimation());
    });
  }
}
