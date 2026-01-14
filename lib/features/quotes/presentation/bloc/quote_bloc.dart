import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/quotes/data/repo/quote_repo.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quote_event.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quote_state.dart';

class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  final repo = QuoteRepo();
  List<dynamic> _currentQuotes = [];
  String? _currentCategory;
  String? _currentSearch;
  String? _currentAuthor;
  int _offset = 0;
  static const _limit = 20;

  QuoteBloc() : super(InitQuoteState()) {
    on<GetQuotesEvent>((event, emit) async {
      emit(LoadingQuoteState());
      try {
        _currentCategory = event.category;
        _currentSearch = event.search;
        _currentAuthor = event.author;
        _offset = 0;

        final quotes = await repo.fetchQuotes(
          category: _currentCategory,
          search: _currentSearch,
          author: _currentAuthor,
          limit: _limit,
          offset: _offset,
        );

        _currentQuotes = quotes;
        _offset = quotes.length;

        emit(LoadedQuoteState(quotes: quotes, hasMore: quotes.length == _limit));
      } catch (e) {
        emit(ErrorQuoteState(e.toString()));
      }
    });

    on<LoadMoreQuotesEvent>((event, emit) async {
      if (state is LoadedQuoteState) {
        final currentState = state as LoadedQuoteState;
        if (!currentState.hasMore) return;

        try {
          final quotes = await repo.fetchQuotes(
            category: _currentCategory,
            search: _currentSearch,
            author: _currentAuthor,
            limit: _limit,
            offset: _offset,
          );

          _currentQuotes.addAll(quotes);
          _offset += quotes.length;

          emit(LoadedQuoteState(
            quotes: List.from(_currentQuotes),
            hasMore: quotes.length == _limit,
          ));
        } catch (e) {
          emit(ErrorQuoteState(e.toString()));
        }
      }
    });

    on<RefreshQuotesEvent>((event, emit) async {
      add(GetQuotesEvent(
        category: _currentCategory,
        search: _currentSearch,
        author: _currentAuthor,
      ));
    });
  }
}
