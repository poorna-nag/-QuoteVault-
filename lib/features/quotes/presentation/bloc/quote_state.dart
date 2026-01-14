import 'package:quote_vault/features/quotes/data/quote_model.dart';

class QuoteState {}

class InitQuoteState extends QuoteState {}

class LoadingQuoteState extends QuoteState {}

class LoadedQuoteState extends QuoteState {
  final List<Quote> quotes;
  final bool hasMore;
  LoadedQuoteState({required this.quotes, this.hasMore = true});
}

class ErrorQuoteState extends QuoteState {
  final String message;
  ErrorQuoteState(this.message);
}
