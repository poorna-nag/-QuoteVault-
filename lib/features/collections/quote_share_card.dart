import 'package:flutter/material.dart';

class QuoteShareCard extends StatelessWidget {
  final String quote;
  final String author;

  const QuoteShareCard({super.key, required this.quote, required this.author});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary.withOpacity(0.9), scheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.format_quote,
            color: scheme.onPrimary.withOpacity(0.8),
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            quote,
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '- $author',
            style: TextStyle(
              color: scheme.onPrimaryContainer.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
