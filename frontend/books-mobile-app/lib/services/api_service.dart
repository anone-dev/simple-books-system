import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/book.dart';
import '../models/order.dart';

/// API service for communicating with Simple Books server.
class ApiService {
  String? _token;

  String? get token => _token;
  set token(String? t) => _token = t;

  Map<String, String> get _headers {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (_token != null) h['Authorization'] = 'Bearer $_token';
    return h;
  }

  Uri _uri(String path, [Map<String, String>? params]) =>
      Uri.parse('${AppConfig.baseUrl}$path').replace(queryParameters: params);

  // --- Auth ---

  Future<String> register(String name, String email, String password) async {
    final r = await http.post(
      _uri('/api-clients'),
      headers: _headers,
      body: jsonEncode({'clientName': name, 'clientEmail': email, 'clientPassword': password}),
    );
    if (r.statusCode == 201) {
      final token = jsonDecode(r.body)['accessToken'];
      _token = token;
      return token;
    }
    throw ApiException(r.statusCode, jsonDecode(r.body)['error'] ?? 'Registration failed');
  }

  Future<String> login(String email, String password) async {
    final r = await http.post(
      _uri('/api-clients/login'),
      headers: _headers,
      body: jsonEncode({'clientEmail': email, 'clientPassword': password}),
    );
    if (r.statusCode == 200) {
      final token = jsonDecode(r.body)['accessToken'];
      _token = token;
      return token;
    }
    throw ApiException(r.statusCode, jsonDecode(r.body)['error'] ?? 'Login failed');
  }

  // --- Books ---

  Future<({List<Book> books, PaginationMeta pagination})> getBooks({
    int page = 1,
    String? type,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': AppConfig.pageSize.toString(),
    };
    if (type != null) params['type'] = type;

    final r = await http.get(_uri('/books', params), headers: _headers);
    if (r.statusCode == 200) {
      final body = jsonDecode(r.body);
      final books = (body['books'] as List).map((b) => Book.fromJson(b)).toList();
      final pagination = PaginationMeta.fromJson(body['pagination']);
      return (books: books, pagination: pagination);
    }
    throw ApiException(r.statusCode, 'Failed to load books');
  }

  Future<Book> getBookDetail(int id) async {
    final r = await http.get(_uri('/books/$id'), headers: _headers);
    if (r.statusCode == 200) return Book.fromJson(jsonDecode(r.body));
    throw ApiException(r.statusCode, jsonDecode(r.body)['error'] ?? 'Book not found');
  }

  // --- Orders ---

  Future<String> createOrder(int bookId, String customerName) async {
    final r = await http.post(
      _uri('/orders'),
      headers: _headers,
      body: jsonEncode({'bookId': bookId, 'customerName': customerName}),
    );
    if (r.statusCode == 201) return jsonDecode(r.body)['orderId'];
    throw ApiException(r.statusCode, jsonDecode(r.body)['error'] ?? 'Order failed');
  }

  Future<List<Order>> getOrders() async {
    final r = await http.get(_uri('/orders'), headers: _headers);
    if (r.statusCode == 200) {
      return (jsonDecode(r.body) as List).map((o) => Order.fromJson(o)).toList();
    }
    throw ApiException(r.statusCode, 'Failed to load orders');
  }

  Future<void> updateOrder(String orderId, String customerName) async {
    final r = await http.patch(
      _uri('/orders/$orderId'),
      headers: _headers,
      body: jsonEncode({'customerName': customerName}),
    );
    if (r.statusCode != 204) {
      throw ApiException(r.statusCode, 'Failed to update order');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    final r = await http.delete(_uri('/orders/$orderId'), headers: _headers);
    if (r.statusCode != 204) {
      throw ApiException(r.statusCode, 'Failed to delete order');
    }
  }

  // --- Admin ---

  Future<void> resetServer() async {
    final r = await http.post(_uri('/server/reset'), headers: _headers);
    if (r.statusCode != 200) throw ApiException(r.statusCode, 'Reset failed');
    _token = null;
  }
}

/// API error with status code and message.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
