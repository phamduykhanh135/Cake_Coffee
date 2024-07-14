import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetail {
  final String productId;
  final String productName;
  int quantity;
  final double price;
  final String note;
  // String id;

  OrderDetail({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.note,
    // this.id = '',
  });

  factory OrderDetail.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrderDetail(
      //   id: doc.id,
      productId: data['product_id'],
      productName: data['product_name'],
      quantity: data['quantity'],
      price: (data['price'] as num).toDouble(),
      note: data['note'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'note': note,
    };
  }

  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'note': note,
    };
  }
}
