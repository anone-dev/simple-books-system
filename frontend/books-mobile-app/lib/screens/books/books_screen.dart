import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/books_provider.dart';
import 'book_detail_screen.dart';

/// Books list screen with filter chips, pagination (load more), and pull-to-refresh.
class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadBooks();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      context.read<BooksProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BooksProvider>();

    return Scaffold(
      appBar: AppBar(
        key: const Key('books_screen_title'),
        title: const Text('Books'),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              key: const Key('books_filter_row'),
              children: [
                _buildChip('All', null, provider),
                const SizedBox(width: 8),
                _buildChip('Fiction', 'fiction', provider),
                const SizedBox(width: 8),
                _buildChip('Non-Fiction', 'non-fiction', provider),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String? type, BooksProvider provider) {
    final isActive = provider.currentFilter == type;
    return FilterChip(
      key: Key('books_filter_${type ?? "all"}'),
      label: Text(label),
      selected: isActive,
      onSelected: (_) => provider.loadBooks(type: type),
    );
  }

  Widget _buildContent(BooksProvider provider) {
    if (provider.error != null && provider.books.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(provider.error!, key: const Key('books_error_message'), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('books_btn_retry'),
              onPressed: () => provider.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        key: const Key('books_list'),
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.books.length + (provider.isLoading ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i == provider.books.length) {
            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
          }
          final book = provider.books[i];
          final isFiction = book.type == 'fiction';
          final coverColor = isFiction ? const Color(0xFF6366F1) : const Color(0xFFF59E0B);
          return Card(
            key: Key('books_item_${book.id}'),
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id))),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Book cover icon
                    Container(
                      key: Key('books_item_cover_${book.id}'),
                      width: 52,
                      height: 68,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            coverColor.withOpacity(0.25),
                            coverColor.withOpacity(0.10),
                          ],
                        ),
                        border: Border.all(color: coverColor.withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: coverColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Book info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          if (book.author != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(book.author!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _badge(isFiction ? 'Fiction' : 'Non-Fiction', isFiction ? const Color(0xFFA5B4FC) : const Color(0xFFFBBF24)),
                              const SizedBox(width: 6),
                              _badge(book.available ? 'In Stock' : 'Out of Stock', book.available ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
    );
  }
}

extension on Color {
  Color get shade700 => this;
}
