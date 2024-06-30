import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  String id;
  String productId;
  int quantity;
  String description; // Thêm trường mô tả vào đơn hàng

  Order({
    required this.id, // Marking id as required
    required this.productId,
    required this.quantity,
    required this.description,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      productId: data['productId'],
      quantity: data['quantity'],
      description: data['description'] ??
          '', // Lấy dữ liệu từ Firestore, cần xử lý khi dữ liệu có thể null
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'description': description, // Thêm mô tả vào Map khi lưu vào Firestore
    };
  }
}
