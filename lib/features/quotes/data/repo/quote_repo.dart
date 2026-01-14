import 'package:quote_vault/features/quotes/data/quote_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuoteRepo {
  final _db = Supabase.instance.client;

  Future<List<Quote>> fetchQuotes({String? category, String? search, String? author, int? limit, int? offset}) async {
    var query = _db.from('quotes').select();

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    if (author != null && author.isNotEmpty) {
      query = query.ilike('author', '%$author%');
    }

    if (search != null && search.isNotEmpty) {
      query = query.or('quote.ilike.%$search%,author.ilike.%$search%');
    }

    dynamic data;
    if (limit != null && offset != null) {
      data = await query.range(offset, offset + limit - 1);
    } else if (limit != null) {
      data = await query.limit(limit);
    } else {
      data = await query;
    }
    return (data as List).map<Quote>((e) => Quote.fromJson(e)).toList();
  }

  Future<List<Quote>> fetchByCategory(String category) async {
    return fetchQuotes(category: category);
  }

  Future<List<Quote>> searchQuotes(String query) async {
    return fetchQuotes(search: query);
  }

  Future<List<Quote>> searchByAuthor(String author) async {
    return fetchQuotes(author: author);
  }

  Future<List<String>> getAuthors() async {
    final data = await _db.from('quotes').select('author');
    final authors = (data as List).map((e) => e['author'] as String).toSet().toList();
    authors.sort();
    return authors;
  }
}