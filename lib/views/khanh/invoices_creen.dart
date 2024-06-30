import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  _InvoicesScreenState createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _limit = 10; // Số lượng hóa đơn trên mỗi trang
  DocumentSnapshot?
      _lastDocument; // Biến lưu trữ document cuối cùng của trang trước

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách hóa đơn'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('invoices')
            .orderBy('date', descending: true)
            .limit(_limit)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Không có hóa đơn nào được tìm thấy'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length + 1,
            itemBuilder: (context, index) {
              if (index == snapshot.data!.docs.length) {
                // Hiển thị nút tải thêm khi đến cuối danh sách
                return _buildLoadMoreButton();
              } else {
                var invoice = snapshot.data!.docs[index];
                var invoiceData = invoice.data() as Map<String, dynamic>;

                return ListTile(
                  title: Text('Hóa đơn ${invoice.id}'),
                  subtitle:
                      Text('Ngày: ${invoiceData['date'].toDate().toString()}'),
                  trailing: Text('${invoiceData['total_amount']} VND'),
                  onTap: () {
                    // Xử lý khi nhấn vào từng hóa đơn để hiển thị chi tiết
                    _showInvoiceDetail(invoice);
                  },
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _loadMoreInvoices();
        },
        child: const Text('Tải thêm'),
      ),
    );
  }

  void _loadMoreInvoices() {
    setState(() {
      _limit += 10; // Tăng số lượng hóa đơn trên mỗi trang khi tải thêm
    });
  }

  void _showInvoiceDetail(DocumentSnapshot invoice) async {
    var invoiceData = invoice.data() as Map<String, dynamic>;
    String tableId = invoiceData['table_id'];

    // Truy vấn Firestore để lấy thông tin chi tiết của bàn
    DocumentSnapshot tableSnapshot = await FirebaseFirestore.instance
        .collection('tables')
        .doc(tableId)
        .get();

    if (!tableSnapshot.exists) {
      print('Không tìm thấy thông tin cho bàn có ID: $tableId');
      return;
    }

    var tableData = tableSnapshot.data() as Map<String, dynamic>;

    // Hiển thị thông tin hóa đơn
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chi tiết hóa đơn ${invoice.id}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ngày: ${invoiceData['date'].toDate().toString()}'),
              const SizedBox(height: 8),
              Text('Nhân viên: ${invoiceData['employee']}'),
              const SizedBox(height: 8),
              Text(
                  'Tên bàn: ${tableData['name']}'), // Thay tableData['name'] bằng trường tên của bàn trong Firestore
              const SizedBox(height: 8),
              Text('Tổng tiền: ${invoiceData['total_amount']} VND'),
              const SizedBox(height: 8),
              const Text('Danh sách sản phẩm:'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildOrderDetails(invoiceData['order_details']),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildOrderDetails(List<dynamic> orderDetails) {
    return orderDetails
        .map((detail) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tên món: ${detail['product_name']}'),
                const SizedBox(height: 4),
                Text('Giá: ${detail['price']} VND'),
                const SizedBox(height: 4),
                Text('Số lượng: ${detail['quantity']}'),
                const SizedBox(height: 8),
              ],
            ))
        .toList();
  }
}
