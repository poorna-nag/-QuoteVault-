import 'package:shared_preferences/shared_preferences.dart';
import 'package:quote_vault/features/quotes/data/quote_model.dart';

class DailyQuoteService {
  static const _keyDailyQuoteId = 'daily_quote_id';
  static const _keyDailyQuoteDate = 'daily_quote_date';

  static Future<Quote?> getDailyQuote(List<Quote> quotes) async {
    if (quotes.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_keyDailyQuoteDate);
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastDate == today) {
      final quoteId = prefs.getString(_keyDailyQuoteId);
      if (quoteId != null) {
        try {
          return quotes.firstWhere((q) => q.id == quoteId);
        } catch (_) {}
      }
    }

    final quote = quotes[DateTime.now().millisecondsSinceEpoch % quotes.length];
    await prefs.setString(_keyDailyQuoteId, quote.id);
    await prefs.setString(_keyDailyQuoteDate, today);

    return quote;
  }
}

