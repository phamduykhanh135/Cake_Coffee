import 'package:cake_coffee/views/khanh/invoices_creen.dart';
import 'package:cake_coffee/views/oder_detail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_coffee/models/khanh/products.dart';
import 'package:cake_coffee/models/khanh/table.dart';
import 'package:intl/intl.dart';

class TableSelectionPage extends StatefulWidget {
  const TableSelectionPage({super.key});

  @override
  _TableSelectionPageState createState() => _TableSelectionPageState();
}

class _TableSelectionPageState extends State<TableSelectionPage> {
  String _selectedTableId = '';
  Tables? _selectedTable;
  List<OrderDetail> _orderDetails = [];

  Future<List<OrderDetail>> _loadOrderDetails(String tableId) async {
    List<OrderDetail> orderDetails = [];
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .doc(tableId)
        .collection('order_details')
        .get();
    for (var doc in snapshot.docs) {
      orderDetails.add(OrderDetail.fromFirestore(doc));
    }
    return orderDetails;
  }

  void _openOrderDialog(Tables table) async {
    setState(() {
      _selectedTable = table;
      _selectedTableId = table.id;
    });
    _orderDetails = await _loadOrderDetails(table.id);
    setState(() {});
  }

  Widget _buildTableList(String title, List<Tables> tables) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1, // Aspect ratio 1:1 for square appearance
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              Tables table = tables[index];
              bool isSelected = table.id == _selectedTableId;

              return GestureDetector(
                onTap: () {
                  if (table.status != 'Mang về') {
                    _openOrderDialog(table);
                  }
                },
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  elevation: isSelected ? 6 : 3,
                  color: isSelected ? Colors.green.shade50 : Colors.white,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (table.status != 'Mang về') {
                          _openOrderDialog(table);
                        }
                      },
                      splashColor: Colors.grey.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Table ${table.name}',
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.green : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Status: ${table.status}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Selection'),
      ),
      body: FutureBuilder<List<Tables>>(
        future:
            fetchTablesFromFirestore(), // Thay fetchTables() bằng hàm lấy danh sách bàn của bạn
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Tables> tables = snapshot.data ?? [];
            return _buildTableList('Tables', tables);
          }
        },
      ),
    );
  }
}
