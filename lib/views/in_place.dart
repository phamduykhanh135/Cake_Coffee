import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:cake_coffee/views/khanh/invoices_creen.dart';
import 'package:cake_coffee/views/oder_detail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_coffee/models/khanh/products.dart';
import 'package:cake_coffee/models/khanh/table.dart';
import 'package:intl/intl.dart';

class In_Place extends StatefulWidget {
  //final String nvName;
  const In_Place({
    super.key,
    // required this.nvName
  });

  @override
  _In_PlaceState createState() => _In_PlaceState();
}

class _In_PlaceState extends State<In_Place> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedTableId; // Biến để lưu trữ ID của bàn được chọn
  List<OrderDetail> _orderDetails = [];
  Tables? _selectedTable;
  bool isPendingApproval = false;
  final int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TabBarView(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: ListView(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('tables').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      List<Tables> tables = snapshot.data!.docs
                          .map((doc) => Tables.fromFirestore(doc))
                          .toList();

                      // Lọc các bàn theo trạng thái và hiển thị thành từng hàng
                      List<Tables> activeTables = tables
                          .where((table) => table.status == 'Đang hoạt động')
                          .toList();
                      List<Tables> pendingApprovalTables = tables
                          .where((table) => table.status == 'Chờ duyệt')
                          .toList();
                      List<Tables> emptyTables = tables
                          .where((table) => table.status == 'empty')
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTableList('Đang hoạt động', activeTables),
                          _buildTableList('Chờ duyệt', pendingApprovalTables),
                          _buildTableList('Trống', emptyTables),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),

            // Cột chứa thông tin sản phẩm trong bàn khi nhấn vào
            Expanded(
                flex: 2,
                child: IndexedStack(index: _selectedIndex, children: [
                  _selectedTable != null
                      ? _buildOrderDetailsColumn()
                      : Container(),
                ])),
            // Cột chứa danh sách sản phẩm
            Expanded(
              flex: 1,
              child: _buildAllProductsColumn(),
            ),
          ],
        ),
        Container(
          child: const Text('hahah'),
        )
      ],
    ));
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
                  setState(() {
                    _selectedTable = table; // Cập nhật bàn được chọn
                    _selectedTableId = table.id;
                    isPendingApproval = table.status == 'Chờ duyệt';
                  });
                  _openOrderDialog(table);
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
                        setState(() {
                          _selectedTableId = table.id;
                          _selectedTable = table;
                          isPendingApproval = table.status == 'Chờ duyệt';
                        });
                        _openOrderDialog(table);
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

  Widget _buildOrderDetailsColumn() {
    if (_selectedTable == null) {
      return const Center(child: Text('Chọn một bàn để xem đơn hàng của nó.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('orders')
          .doc(_selectedTable!.id)
          .collection('order_details')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        List<OrderDetail> orderDetails = snapshot.data!.docs
            .map((doc) => OrderDetail.fromFirestore(doc))
            .toList();
        double totalAmount = orderDetails.fold(
          0,
          (previousValue, element) =>
              previousValue + (element.quantity * element.price),
        );
        print(
            'isPendingApproval in buildOrderDetailsColumn: $isPendingApproval');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color.fromARGB(255, 207, 205, 205),
              margin: const EdgeInsets.all(0),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bàn: ${_selectedTable!.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text('Danh sách thực đơn'),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              elevation: 3,
              child: Container(
                child: Container(
                  color: const Color.fromARGB(255, 207, 205, 205),
                  margin: const EdgeInsets.all(0),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('STT'),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Tên món'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Giá'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Số lượng'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Thành tiền'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Mô tả'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: orderDetails.map((orderDetail) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showProductDetailDialog(orderDetail),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    '${orderDetails.indexOf(orderDetail) + 1}'),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(orderDetail.productName),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${orderDetail.price} VND'),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('${orderDetail.quantity}'),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    '${(orderDetail.quantity * orderDetail.price).toStringAsFixed(2)} VND'),
                              ),
                            ),
                            const Expanded(
                              flex: 2,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Your description here'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              elevation: 3,
              child: ListTile(
                title: const Text('Total Amount:'),
                subtitle: Text('${totalAmount.toStringAsFixed(2)} VND'),
              ),
            ),
            const SizedBox(height: 16),
            if (isPendingApproval)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTable!.status = 'Đang hoạt động';
                      isPendingApproval = false;
                    });
                    _firestore
                        .collection('tables')
                        .doc(_selectedTable!.id)
                        .update({'status': 'Đang hoạt động'});
                  },
                  child: const Text('Duyệt đơn'),
                ),
              ),
            const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () {
            //     _exportInvoice(
            //       orderDetails,
            //       "",
            //       // widget.nvName, // Tên nhân viên để trống
            //       _selectedTable!.id, // ID bàn
            //     );
            //   },
            //   child: const Text('Xuất hóa đơn'),
            // ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InvoicesScreen(),
                  ),
                );
              },
              child: const Text('Xem tất cả hóa đơn'),
            ),
          ],
        );
      },
    );
  }

  void _showProductDetailDialog(OrderDetail orderDetail) {
    int quantity = orderDetail.quantity;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(orderDetail.productName),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Price: ${orderDetail.price} VND'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                      ),
                      Text(quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    _removeOrderDetail(orderDetail);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    _updateOrderDetailQuantity(orderDetail, quantity);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateOrderDetailQuantity(
      OrderDetail orderDetail, int newQuantity) async {
    if (_selectedTable != null) {
      // Cập nhật số lượng sản phẩm trong đơn hàng của bàn
      await _firestore
          .collection('orders')
          .doc(_selectedTable!.id)
          .collection('order_details')
          .doc(orderDetail.productId)
          .update({
        'quantity': newQuantity,
      });

      for (var detail in _orderDetails) {
        if (detail.productId == orderDetail.productId) {
          detail.quantity = newQuantity;
        }
      }
    }
  }

  Widget _buildAllProductsColumn() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        List<Product> products = snapshot.data!.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList();
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            Product product = products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('${product.price} VND'),
              onTap: () => _showAddQuantityDialog(product),
            );
          },
        );
      },
    );
  }

  void _openOrderDialog(Tables table) async {
    _selectedTable = table;
    _orderDetails = await _loadOrderDetails(table.id);
    setState(() {});
  }

  void _showAddQuantityDialog(Product product) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add ${product.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Price: ${product.price} VND'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () async {
                    _addToOrder(product, quantity);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addToOrder(Product product, int quantity) async {
    if (_selectedTable != null) {
      // Thêm sản phẩm vào đơn hàng của bàn
      await _firestore
          .collection('orders')
          .doc(_selectedTable!.id)
          .collection('order_details')
          .doc(product.id)
          .set({
        'product_id': product.id,
        'product_name': product.name,
        'quantity': quantity,
        'price': product.price,
      });

      await _updateTableStatus(_selectedTable!.id);
    }
  }

  void _removeOrderDetail(OrderDetail orderDetail) async {
    if (_selectedTable != null) {
      // Xóa sản phẩm khỏi đơn hàng của bàn
      await _firestore
          .collection('orders')
          .doc(_selectedTable!.id)
          .collection('order_details')
          .doc(orderDetail.productId)
          .delete();

      // Cập nhật trạng thái của bàn trong cơ sở dữ liệu
      await _updateTableStatus(_selectedTable!.id);
    }
  }

  Future<void> _updateTableStatus(String tableId) async {
    // Kiểm tra số lượng sản phẩm trong đơn hàng của bàn
    QuerySnapshot querySnapshot = await _firestore
        .collection('orders')
        .doc(tableId)
        .collection('order_details')
        .get();

    // Tính số lượng sản phẩm
    int itemCount = querySnapshot.docs.length;

    // Cập nhật trạng thái của bàn
    String tableStatus = itemCount > 0 ? 'Chờ duyệt' : 'empty';
    await _firestore.collection('tables').doc(tableId).update({
      'status': tableStatus,
    });
  }

  void _saveOrder() async {
    if (_selectedTable != null && _orderDetails.isNotEmpty) {
      // Lưu đơn hàng vào Firestore
      for (var orderDetail in _orderDetails) {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(_selectedTable!.id)
            .collection('order_details')
            .doc(orderDetail.productId)
            .set({
          'product_id': orderDetail.productId,
          'product_name': orderDetail.productName,
          'quantity': orderDetail.quantity,
          'price': orderDetail.price,
        });
      }
      await _updateTableStatus(_selectedTable!.id);
    }
  }

  Future<void> _TableStatus(String tableId) async {
    // Kiểm tra số lượng sản phẩm trong đơn hàng của bàn
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .doc(tableId)
        .collection('order_details')
        .get();
    int itemCount = querySnapshot.docs.length;
    String tableStatus = 'Đang hoạt động';
    await FirebaseFirestore.instance.collection('tables').doc(tableId).update({
      'status': tableStatus,
    });
  }

  Future<List<OrderDetail>> _loadOrderDetails(String tableId) async {
    List<OrderDetail> orderDetails = [];
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .doc(tableId)
          .collection('order_details')
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          orderDetails.add(OrderDetail.fromFirestore(doc));
        }
      } else {
        print('No order details found for table $tableId');
      }
    } catch (e) {
      print('Error loading order details: $e');
      // Handle error appropriately, e.g., show error message to the user
    }

    return orderDetails;
  }
}
