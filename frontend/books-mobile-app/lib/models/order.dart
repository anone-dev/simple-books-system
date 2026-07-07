/// Order model.
class Order {
  final String id;
  final int bookId;
  final String customerName;
  final String? timestamp;

  Order({
    required this.id,
    required this.bookId,
    required this.customerName,
    this.timestamp,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      bookId: json['bookId'],
      customerName: json['customerName'],
      timestamp: json['timestamp'],
    );
  }
}
