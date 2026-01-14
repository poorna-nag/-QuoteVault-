import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/collections/presentation/bloc/collections_event.dart';
import 'package:quote_vault/features/collections/presentation/bloc/collections_state.dart'
    show
        CollectionsState,
        CollectionsInitial,
        CollectionsLoading,
        CollectionsLoaded,
        CollectionsError;
import 'package:quote_vault/features/collections/data/collection_repo.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final repo = CollectionRepo();

  CollectionsBloc() : super(CollectionsInitial()) {
    on<LoadCollectionsEvent>((event, emit) async {
      emit(CollectionsLoading());
      try {
        final collections = await repo.fetchCollections();
        emit(CollectionsLoaded(collections));
      } catch (e) {
        emit(CollectionsError(e.toString()));
      }
    });

    on<CreateCollectionEvent>((event, emit) async {
      try {
        await repo.createCollection(event.name);
        add(LoadCollectionsEvent());
      } catch (e) {
        emit(CollectionsError(e.toString()));
      }
    });

    on<AddQuoteToCollectionEvent>((event, emit) async {
      try {
        await repo.addQuoteToCollection(event.collectionId, event.quoteId);
        add(LoadCollectionsEvent());
      } catch (e) {
        emit(CollectionsError(e.toString()));
      }
    });
  }
}
