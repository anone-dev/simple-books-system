import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';

/// Books state management with pagination.
class BooksProvider extends ChangeNotifier {
  final ApiService _api;

  List<Book> _books = [];
  PaginationMeta? _pagination;
  bool _isLoading = false;
  String? _error;
  String? _currentFilter;
  int _currentPage = 1;

  BooksProvider(this._api);

  List<Book> get books => _books;
  PaginationMeta? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentFilter => _currentFilter;
  int get currentPage => _currentPage;
  bool get hasMore => _pagination != null && _currentPage < _pagination!.totalPages;

  /// Load books (replaces current list).
  Future<void> loadBooks({String? type, int page = 1}) async {
    _isLoading = true;
    _error = null;
    _currentFilter = type;
    _currentPage = page;
    notifyListeners();
    try {
      final result = await _api.getBooks(page: page, type: type);
      _books = result.books;
      _pagination = result.pagination;
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Network error. Please check your connection.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load next page and append to list (infinite scroll).
  Future<void> loadMore() async {
    if (!hasMore || _isLoading) return;
    _currentPage++;
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _api.getBooks(page: _currentPage, type: _currentFilter);
      _books.addAll(result.books);
      _pagination = result.pagination;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _currentPage--;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh (reset to page 1).
  Future<void> refresh() async {
    await loadBooks(type: _currentFilter, page: 1);
  }

  /// Get book detail.
  Future<Book> getBookDetail(int id) async {
    return await _api.getBookDetail(id);
  }
}
