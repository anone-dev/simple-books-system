/// Book model for list and detail views.
class Book {
  final int id;
  final String name;
  final String type;
  final bool available;
  final String? author;
  final double? price;
  final int? currentStock;

  Book({
    required this.id,
    required this.name,
    required this.type,
    required this.available,
    this.author,
    this.price,
    this.currentStock,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      available: json['available'],
      author: json['author'],
      price: json['price']?.toDouble(),
      currentStock: json['current-stock'],
    );
  }
}

/// Pagination metadata from API response.
class PaginationMeta {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PaginationMeta({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['currentPage'],
      pageSize: json['pageSize'],
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
    );
  }
}
