import 'package:quote_vault/features/quotes/data/quote_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesRepo {
  final _db = Supabase.instance.client;

  Future<void> addFavorite(String quoteId) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return;

    await _db.from('favorites').insert({
      'user_id': userId,
      'quote_id': quoteId,
    });
  }

  Future<void> removeFavorite(String quoteId) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return;

    await _db
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('quote_id', quoteId);
  }

  Future<bool> isFavorite(String quoteId) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return false;

    final result = await _db
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('quote_id', quoteId)
        .maybeSingle();

    return result != null;
  }

  Future<List<String>> getFavoriteIds() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];

    final result = await _db
        .from('favorites')
        .select('quote_id')
        .eq('user_id', userId);
    return (result as List).map((e) => e['quote_id'] as String).toList();
  }

  Future<List<Quote>> getFavorites() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];

    final ids = await getFavoriteIds();
    if (ids.isEmpty) return [];

    final result = await _db.from('quotes').select().inFilter('id', ids);

    return (result as List)
        .map((e) => Quote.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
