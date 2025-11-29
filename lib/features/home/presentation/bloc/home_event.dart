sealed class HomeEvent {}

class LoadCategories extends HomeEvent {}

class SelectCategory extends HomeEvent {
  final String categoryId;

  SelectCategory(this.categoryId);
}
