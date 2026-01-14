import 'package:flutter/material.dart';
import 'package:quote_vault/features/quotes/data/repo/favorites_repo.dart';
import 'package:quote_vault/features/quotes/data/quote_model.dart';
import 'package:quote_vault/features/quotes/presentation/quote_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final bool embed;

  const FavoritesScreen({super.key, this.embed = false});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _repo = FavoritesRepo();
  List<Quote> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    final favorites = await _repo.getFavorites();
    setState(() {
      _favorites = favorites;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : _favorites.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: scheme.primary.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on a quote to save it here.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadFavorites,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final quote = _favorites[index];

                return Material(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 1,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, animation, secondaryAnimation) =>
                              QuoteDetailScreen(quote: quote),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      ).then((_) => _loadFavorites());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quote.quote,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '— ${quote.author}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: scheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: scheme.onSurface.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );

    if (widget.embed) return content;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites'), centerTitle: true),
      body: content,
    );
  }
}
