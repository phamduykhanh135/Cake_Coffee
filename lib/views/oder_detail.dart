import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetail {
  final String productId;
  final String productName;
  int quantity; // Change to non-final
  final double price;

  OrderDetail({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderDetail.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrderDetail(
      productId: data['product_id'],
      productName: data['product_name'],
      quantity: data['quantity'],
      price: (data['price'] as num).toDouble(),
    );
  }

  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
  }
}
