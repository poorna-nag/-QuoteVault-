import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/constants.dart';
import 'package:quote_vault/core/services/daily_quote_service.dart';
import 'package:quote_vault/core/services/preferences_service.dart';
import 'package:quote_vault/features/collections/collections_screen.dart';
import 'package:quote_vault/features/quotes/data/quote_model.dart';
import 'package:quote_vault/features/quotes/data/repo/quote_repo.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quote_bloc.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quote_event.dart';
import 'package:quote_vault/features/quotes/presentation/bloc/quote_state.dart';
import 'package:quote_vault/features/quotes/presentation/favorites_screen.dart';
import 'package:quote_vault/features/quotes/presentation/quote_detail_screen.dart';
import 'package:quote_vault/features/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String? _selectedCategory;
  Quote? _dailyQuote;
  List<String> _authors = [];
  double _fontSize = 18.0;
  int _currentIndex = 0;
  Color appBarColor = const Color(0xFF1B3A2E);

  @override
  void initState() {
    super.initState();
    _loadFontSize();
    _loadAuthors();
    _scrollController.addListener(_onScroll);
    context.read<QuoteBloc>().add(GetQuotesEvent());
  }

  Future<void> _loadFontSize() async {
    final size = await PreferencesService.getFontSize();
    setState(() => _fontSize = size);
  }

  Future<void> _loadAuthors() async {
    final repo = QuoteRepo();
    final authors = await repo.getAuthors();
    setState(() => _authors = authors);
  }

  Future<void> _loadDailyQuote() async {
    if (context.read<QuoteBloc>().state is LoadedQuoteState) {
      final state = context.read<QuoteBloc>().state as LoadedQuoteState;
      final daily = await DailyQuoteService.getDailyQuote(state.quotes);
      setState(() => _dailyQuote = daily);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<QuoteBloc>().add(LoadMoreQuotesEvent());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titles = ['QuoteVault', 'Favorites', 'Collections', 'Settings'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final controller = TextEditingController();
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Search Quotes'),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search by quote or author',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<QuoteBloc>().add(
                            GetQuotesEvent(search: controller.text),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Search'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'authors', child: Text('Filter by Author')),
            ],
            onSelected: (value) {
              if (value == 'authors') {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Select Author'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _authors.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_authors[index]),
                              onTap: () {
                                context.read<QuoteBloc>().add(
                                  GetQuotesEvent(author: _authors[index]),
                                );
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: [
          /// HOME
          BlocBuilder<QuoteBloc, QuoteState>(
            builder: (context, state) {
              if (state is LoadingQuoteState) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ErrorQuoteState) {
                return Center(child: Text(state.message));
              }

              if (state is LoadedQuoteState) {
                if (_dailyQuote == null) {
                  _loadDailyQuote();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<QuoteBloc>().add(RefreshQuotesEvent());
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      /// QUOTE OF THE DAY
                      if (_dailyQuote != null)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuoteDetailScreen(
                                        quote: _dailyQuote!,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      'QUOTE OF THE DAY',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                            letterSpacing: 1.2,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _dailyQuote!.quote,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '- ${_dailyQuote!.author}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme.colorScheme.onPrimary
                                                .withOpacity(0.9),
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      /// CATEGORY CHIPS
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 48,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: AppConstants.categories.length + 1,
                            itemBuilder: (context, index) {
                              final isAll = index == 0;
                              final category = isAll
                                  ? 'All'
                                  : AppConstants.categories[index - 1];
                              final selected = isAll
                                  ? _selectedCategory == null
                                  : _selectedCategory == category;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: ChoiceChip(
                                  label: Text(category),
                                  selected: selected,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedCategory = isAll
                                          ? null
                                          : category;
                                    });
                                    context.read<QuoteBloc>().add(
                                      GetQuotesEvent(
                                        category: isAll ? null : category,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      /// QUOTE LIST
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= state.quotes.length) {
                              return state.hasMore
                                  ? const Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            }

                            final quote = state.quotes[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    quote.quote,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: _fontSize,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      quote.author,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, a, __) =>
                                            QuoteDetailScreen(quote: quote),
                                        transitionsBuilder:
                                            (_, animation, __, child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          childCount:
                              state.quotes.length + (state.hasMore ? 1 : 0),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          const FavoritesScreen(embed: true),
          const CollectionsScreen(embed: true),
          const SettingsScreen(embed: true),
        ],
      ),

      /// BOTTOM NAV
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
          NavigationDestination(icon: Icon(Icons.folder), label: 'Collections'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
