import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionRepo {
  final _db = Supabase.instance.client;

  Future<void> createCollection(String name) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    await _db.from('collections').insert({
      'name': name,
      'user_id': userId,
    });
  }

  Future<List<Map<String, dynamic>>> fetchCollections() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];

    return await _db.from('collections').select().eq('user_id', userId);
  }

  Future<void> addQuoteToCollection(String collectionId, String quoteId) async {
    await _db.from('collection_quotes').insert({
      'collection_id': collectionId,
      'quote_id': quoteId,
    });
  }

  Future<void> removeQuoteFromCollection(String collectionId, String quoteId) async {
    await _db
        .from('collection_quotes')
        .delete()
        .eq('collection_id', collectionId)
        .eq('quote_id', quoteId);
  }

  Future<List<Map<String, dynamic>>> getCollectionQuotes(String collectionId) async {
    final result = await _db
        .from('collection_quotes')
        .select('quote_id, quotes(*)')
        .eq('collection_id', collectionId);

    return (result as List).map((e) {
      return {
        'quote_id': e['quote_id'],
        'quote': e['quotes'],
      };
    }).toList();
  }

  Future<void> deleteCollection(String collectionId) async {
    await _db.from('collection_quotes').delete().eq('collection_id', collectionId);
    await _db.from('collections').delete().eq('id', collectionId);
  }
}