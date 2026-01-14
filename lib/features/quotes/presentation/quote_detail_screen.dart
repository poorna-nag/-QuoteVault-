import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:quote_vault/features/collections/presentation/bloc/collections_bloc.dart';
import 'package:quote_vault/features/collections/collections_screen.dart';
import 'package:quote_vault/features/collections/presentation/bloc/collections_event.dart';
import 'package:quote_vault/features/quotes/data/quote_model.dart';
import 'package:quote_vault/features/quotes/data/repo/favorites_repo.dart';
import 'package:quote_vault/features/quotes/presentation/quote_card_styles.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class QuoteDetailScreen extends StatefulWidget {
  final Quote quote;

  const QuoteDetailScreen({super.key, required this.quote});

  @override
  State<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends State<QuoteDetailScreen> {
  final _favoritesRepo = FavoritesRepo();
  bool _isFavorite = false;
  int _selectedStyle = 0;
  final _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final isFav = await _favoritesRepo.isFavorite(widget.quote.id);
    setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoritesRepo.removeFavorite(widget.quote.id);
    } else {
      await _favoritesRepo.addFavorite(widget.quote.id);
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  Future<void> _shareAsText() async {
    await Share.share('${widget.quote.quote}\n\n- ${widget.quote.author}');
  }

  Future<void> _shareAsImage() async {
    final image = await _screenshotController.capture();
    if (image == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/quote_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(image);

    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> _saveImage() async {
    final image = await _screenshotController.capture();
    if (image == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/quote_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(image);

    await GallerySaver.saveImage(file.path);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image saved to gallery')));
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image saved to gallery')));
    }
  }

  Widget _buildQuoteCard() {
    switch (_selectedStyle) {
      case 0:
        return QuoteCardStyle1(
          quote: widget.quote.quote,
          author: widget.quote.author,
        );
      case 1:
        return QuoteCardStyle2(
          quote: widget.quote.quote,
          author: widget.quote.author,
        );
      case 2:
        return QuoteCardStyle3(
          quote: widget.quote.quote,
          author: widget.quote.author,
        );
      default:
        return QuoteCardStyle1(
          quote: widget.quote.quote,
          author: widget.quote.author,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote'),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Screenshot(
              controller: _screenshotController,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey(_selectedStyle),
                  child: _buildQuoteCard(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedStyle = (_selectedStyle + 1) % 3;
                    });
                  },
                  icon: const Icon(Icons.palette),
                  label: const Text('Change Style'),
                ),
                ElevatedButton.icon(
                  onPressed: _shareAsText,
                  icon: const Icon(Icons.share),
                  label: const Text('Share Text'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _shareAsImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Share Image'),
                ),
                ElevatedButton.icon(
                  onPressed: _saveImage,
                  icon: const Icon(Icons.download),
                  label: const Text('Save Image'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CollectionsBloc>().add(LoadCollectionsEvent());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddToCollectionScreen(quoteId: widget.quote.id),
                  ),
                );
              },
              icon: const Icon(Icons.folder),
              label: const Text('Add to Collection'),
            ),
          ],
        ),
      ),
    );
  }
}
