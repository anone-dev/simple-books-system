import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/books_provider.dart';
import '../../providers/orders_provider.dart';
import '../../services/api_service.dart';

/// Book detail screen with order placement.
class BookDetailScreen extends StatefulWidget {
  final int bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _customerNameController = TextEditingController();
  Book? _book;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  Future<void> _loadBook() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final book = await context.read<BooksProvider>().getBookDetail(widget.bookId);
      setState(() { _book = book; _isLoading = false; });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Failed to load book details.'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: const Key('detail_screen_title'),
        title: const Text('Book Detail'),
        leading: IconButton(
          key: const Key('detail_btn_back'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, key: const Key('detail_error_message')));
    }
    if (_book == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book icon
          Center(child: Icon(Icons.auto_stories, size: 80, color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 16),

          // Title and author
          Center(child: Text(_book!.name, key: const Key('detail_book_title'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
          const SizedBox(height: 4),
          Center(child: Text(_book!.author ?? '', key: const Key('detail_book_author'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey))),
          const SizedBox(height: 24),

          // Info rows
          _infoRow('Type', _book!.type, const Key('detail_book_type')),
          _infoRow('Price', '\$${_book!.price?.toStringAsFixed(2) ?? "—"}', const Key('detail_book_price')),
          _infoRow('Stock', _book!.available ? 'In Stock (${_book!.currentStock})' : 'Out of Stock',
            const Key('detail_book_stock'), color: _book!.available ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
          _infoRow('Book ID', '${_book!.id}', const Key('detail_book_id')),
          const SizedBox(height: 32),

          // Order section
          Text('Place Order', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            key: const Key('detail_input_customer'),
            controller: _customerNameController,
            decoration: const InputDecoration(labelText: 'Customer Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('detail_btn_order'),
              onPressed: _book!.available || _book!.id == 3 ? _placeOrder : null,
              child: Text(_book!.available ? 'Order This Book' : 'Out of Stock'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Key key, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, key: key, style: TextStyle(fontWeight: FontWeight.w500, color: color ?? Colors.white)),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    final name = _customerNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter customer name')),
      );
      return;
    }

    final orderId = await context.read<OrdersProvider>().createOrder(_book!.id, name);
    if (mounted) {
      if (orderId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(key: const Key('detail_snackbar_success'), content: Text('Order created: $orderId')),
        );
      } else {
        final error = context.read<OrdersProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(key: const Key('detail_snackbar_error'), content: Text(error ?? 'Order failed'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
