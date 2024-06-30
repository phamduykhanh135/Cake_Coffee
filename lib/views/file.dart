// void _exportInvoice(
//     List<OrderDetail> orderDetails, String employeeName, String tableId) {
//   double totalAmount = _calculateTotalAmount(orderDetails);

//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Xác nhận xuất hóa đơn'),
//         content: SizedBox(
//           width: 300.0, // Đặt chiều rộng cố định
//           height: 400.0, // Đặt chiều cao cố định
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Danh sách sản phẩm:'),
//               Expanded(
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: orderDetails.length,
//                   itemBuilder: (context, index) {
//                     OrderDetail orderDetail = orderDetails[index];
//                     return ListTile(
//                       title: Text(orderDetail.productName),
//                       subtitle: Text('Số lượng: ${orderDetail.quantity}'),
//                     );
//                   },
//                 ),
//               ),
//               ListTile(
//                 title: const Text('Tổng cộng:'),
//                 subtitle: Text('${totalAmount.toStringAsFixed(2)} VND'),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Đóng dialog khi nhấn Hủy
//             },
//             child: const Text('Hủy'),
//           ),
//           TextButton(
//             onPressed: () async {
//               // Lưu hóa đơn vào Firestore
//               await _saveInvoiceToFirestore(
//                   orderDetails, totalAmount, employeeName, tableId);
//               // Xóa các sản phẩm trong bàn sau khi lưu hóa đơn
//               await _clearTableOrderDetails(tableId);
//               Navigator.of(context)
//                   .pop(); // Đóng dialog sau khi lưu hóa đơn và xóa sản phẩm
//             },
//             child: const Text('Xác nhận'),
//           ),
//         ],
//       );
//     },
//   );
// }

// Future<void> _saveInvoiceToFirestore(List<OrderDetail> orderDetails,
//     double totalAmount, String employeeName, String tableId) async {
//   try {
//     // Chuẩn bị danh sách chi tiết đơn hàng
//     List<Map<String, dynamic>> orderDetailsData = orderDetails.map((detail) {
//       return {
//         'price': detail.price.toDouble(),
//         'product_id': detail.productId,
//         'product_name': detail.productName,
//         'quantity': detail.quantity,
//       };
//     }).toList();

//     // Tạo một document mới trong collection 'invoices'
//     await FirebaseFirestore.instance.collection('invoices').add({
//       'date': DateTime.now(),
//       'employee': employeeName,
//       'order_details': orderDetailsData,
//       'table_id': tableId,
//       'total_amount': totalAmount,
//     });

//     print('Hóa đơn đã được lưu thành công');
//   } catch (e) {
//     print('Lỗi khi lưu hóa đơn: $e');
//   }
// }

// Future<void> _clearTableOrderDetails(String tableId) async {
//   try {
//     WriteBatch batch = FirebaseFirestore.instance.batch();

//     QuerySnapshot orderDetailsSnapshot = await FirebaseFirestore.instance
//         .collection('orders')
//         .doc(tableId)
//         .collection('order_details')
//         .get();

//     for (DocumentSnapshot doc in orderDetailsSnapshot.docs) {
//       batch.delete(doc.reference);
//     }

//     // Cập nhật trạng thái bàn
//     DocumentReference tableRef =
//         FirebaseFirestore.instance.collection('tables').doc(tableId);
//     batch.update(tableRef, {'status': 'empty'});

//     await batch.commit();

//     print(
//         'Đã xóa các sản phẩm trong bàn và cập nhật trạng thái bàn thành công');
//   } catch (e) {
//     print('Lỗi khi xóa các sản phẩm trong bàn: $e');
//   }
// }

// double _calculateTotalAmount(List<OrderDetail> orderDetails) {
//   double totalAmount = 0.0;
//   for (var orderDetail in orderDetails) {
//     totalAmount += orderDetail.quantity * orderDetail.price;
//   }
//   return totalAmount;
// }
