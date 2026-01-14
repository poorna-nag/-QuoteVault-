class QuoteEvent {}

class GetQuotesEvent extends QuoteEvent {
  final String? category;
  final String? search;
  final String? author;
  GetQuotesEvent({this.category, this.search, this.author});
}

class LoadMoreQuotesEvent extends QuoteEvent {}

class RefreshQuotesEvent extends QuoteEvent {}
