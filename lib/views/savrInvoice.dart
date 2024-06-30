import 'package:cake_coffee/views/oder_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> _saveInvoiceToFirestore(List<OrderDetail> orderDetails,
    double totalAmount, String employeeName, String tableId) async {
  try {
    // Chuẩn bị danh sách chi tiết đơn hàng
    List<Map<String, dynamic>> orderDetailsData = orderDetails.map((detail) {
      return {
        'price': detail.price,
        'product_id': detail.productId,
        'product_name': detail.productName,
        'quantity': detail.quantity,
      };
    }).toList();

    // Tạo một document mới trong collection 'invoices'
    await FirebaseFirestore.instance.collection('invoices').add({
      'date': Timestamp.now(),
      'employee': employeeName,
      'order_details': orderDetailsData,
      'table_id': tableId,
      'total_amount': totalAmount,
    });

    print('Hóa đơn đã được lưu thành công');
  } catch (e) {
    print('Lỗi khi lưu hóa đơn: $e');
  }
}
