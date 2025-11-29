import 'package:equatable/equatable.dart';

class AlgorithmCategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int algorithmCount;

  const AlgorithmCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.algorithmCount,
  });

  @override
  List<Object?> get props => [id, name, description, icon, algorithmCount];
}

sealed class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<AlgorithmCategory> categories;

  HomeLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
