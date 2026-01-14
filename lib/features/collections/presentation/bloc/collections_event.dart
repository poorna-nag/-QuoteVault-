abstract class CollectionsEvent {}

class LoadCollectionsEvent extends CollectionsEvent {}

class CreateCollectionEvent extends CollectionsEvent {
  final String name;
  CreateCollectionEvent(this.name);
}

class AddQuoteToCollectionEvent extends CollectionsEvent {
  final String collectionId;
  final String quoteId;
  AddQuoteToCollectionEvent(this.collectionId, this.quoteId);
}