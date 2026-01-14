import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/features/collections/presentation/bloc/collections_bloc.dart';
import 'package:quote_vault/features/collections/data/collection_repo.dart';
import 'package:quote_vault/features/collections/presentation/bloc/collections_event.dart';
import 'package:quote_vault/features/collections/presentation/bloc/collections_state.dart';
import 'package:quote_vault/features/quotes/data/quote_model.dart';

/// =======================
/// COLLECTIONS LIST SCREEN
/// =======================
class CollectionsScreen extends StatelessWidget {
  final bool embed;

  const CollectionsScreen({super.key, this.embed = false});

  @override
  Widget build(BuildContext context) {
    context.read<CollectionsBloc>().add(LoadCollectionsEvent());
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final body = BlocBuilder<CollectionsBloc, CollectionsState>(
      builder: (context, state) {
        if (state is CollectionsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CollectionsError) {
          return Center(child: Text(state.message));
        }

        if (state is CollectionsLoaded) {
          if (state.collections.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: scheme.primary.withOpacity(0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No collections yet',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create a collection to organize quotes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.collections.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final collection = state.collections[index];

              return Material(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                elevation: 1,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CollectionDetailScreen(
                          collectionId: collection['id'],
                          collectionName: collection['name'],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.folder, color: scheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            collection['name'] ?? '',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline),
                          onPressed: () async {
                            await CollectionRepo().deleteCollection(
                              collection['id'],
                            );
                            context.read<CollectionsBloc>().add(
                              LoadCollectionsEvent(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );

    Widget fab(BuildContext context) {
      return FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Collection'),
        onPressed: () => _showCreateDialog(context),
      );
    }

    if (embed) {
      return Stack(
        children: [
          body,
          Positioned(bottom: 16, right: 16, child: fab(context)),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Collections'), centerTitle: true),
      body: body,
      floatingActionButton: fab(context),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('New Collection'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Collection name',
              prefixIcon: Icon(Icons.folder),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<CollectionsBloc>().add(
                    CreateCollectionEvent(controller.text),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

/// ==========================
/// COLLECTION DETAIL SCREEN
/// ==========================
class CollectionDetailScreen extends StatefulWidget {
  final String collectionId;
  final String collectionName;

  const CollectionDetailScreen({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  final _repo = CollectionRepo();
  List<Map<String, dynamic>> _quotes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    setState(() => _loading = true);
    final quotes = await _repo.getCollectionQuotes(widget.collectionId);
    setState(() {
      _quotes = quotes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.collectionName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _quotes.isEmpty
          ? Center(
              child: Text(
                'No quotes in this collection',
                style: theme.textTheme.bodyLarge,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _quotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final quoteData =
                    _quotes[index]['quote'] as Map<String, dynamic>;
                final quote = Quote.fromJson(quoteData);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(quote.quote),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        quote.author,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: scheme.error),
                      onPressed: () async {
                        await _repo.removeQuoteFromCollection(
                          widget.collectionId,
                          quote.id,
                        );
                        _loadQuotes();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// ============================
/// ADD TO COLLECTION SCREEN
/// ============================
class AddToCollectionScreen extends StatefulWidget {
  final String quoteId;

  const AddToCollectionScreen({super.key, required this.quoteId});

  @override
  State<AddToCollectionScreen> createState() => _AddToCollectionScreenState();
}

class _AddToCollectionScreenState extends State<AddToCollectionScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add to Collection')),
      body: BlocBuilder<CollectionsBloc, CollectionsState>(
        builder: (context, state) {
          if (state is CollectionsLoaded) {
            if (state.collections.isEmpty) {
              return Center(
                child: Text(
                  'No collections available.\nCreate one first.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.collections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final collection = state.collections[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(collection['name'] ?? ''),
                    onTap: () {
                      context.read<CollectionsBloc>().add(
                        AddQuoteToCollectionEvent(
                          collection['id'],
                          widget.quoteId,
                        ),
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to collection')),
                      );
                    },
                  ),
                );
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
