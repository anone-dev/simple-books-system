import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

/// Orders state management.
class OrdersProvider extends ChangeNotifier {
  final ApiService _api;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  OrdersProvider(this._api);

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all orders for the authenticated client.
  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _api.getOrders();
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

  /// Create a new order.
  Future<String?> createOrder(int bookId, String customerName) async {
    try {
      final orderId = await _api.createOrder(bookId, customerName);
      await loadOrders();
      return orderId;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  /// Update an order's customer name.
  Future<bool> updateOrder(String orderId, String customerName) async {
    try {
      await _api.updateOrder(orderId, customerName);
      await loadOrders();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Delete an order.
  Future<bool> deleteOrder(String orderId) async {
    try {
      await _api.deleteOrder(orderId);
      _orders.removeWhere((o) => o.id == orderId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}
