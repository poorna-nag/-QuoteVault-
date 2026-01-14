abstract class CollectionsState {}

class CollectionsInitial extends CollectionsState {}

class CollectionsLoading extends CollectionsState {}

class CollectionsLoaded extends CollectionsState {
  final List<Map<String, dynamic>> collections;
  CollectionsLoaded(this.collections);
}

class CollectionsError extends CollectionsState {
  final String message;
  CollectionsError(this.message);
}