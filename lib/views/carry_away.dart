import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:cake_coffee/views/khanh/invoices_creen.dart';
import 'package:cake_coffee/views/oder_detail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_coffee/models/khanh/products.dart';
import 'package:intl/intl.dart';

class Carry_Away extends StatefulWidget {
  const Carry_Away({super.key});

  @override
  _Carry_AwayState createState() => _Carry_AwayState();
}

class _Carry_AwayState extends State<Carry_Away> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<OrderDetail> _orderDetails = [];
  final int _selectedIndex = 0;
  final List<Order> _orders = []; // Danh sách các đơn hàng

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<List<OrderDetail>> _loadOrderDetails() async {
    List<OrderDetail> orderDetails = [];
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .doc('carry_away')
          .collection('order_details')
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          orderDetails.add(OrderDetail.fromFirestore(doc));
        }
      } else {}
    } catch (e) {
      print('Error loading order details: $e');
    }

    return orderDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột chứa danh sách sản phẩm
          Expanded(
            flex: 4,
            child: _buildOrderDetailsColumn(),
          ),
          // Cột chứa thông tin sản phẩm đã đặt hàng
          Expanded(
            flex: 2,
            child: _buildAllProductsColumn(),
          ),
        ],
      ),
    );
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
    // Tạo một đối tượng OrderDetail mới để lưu thông tin sản phẩm vào đơn hàng
    OrderDetail orderDetail = OrderDetail(
      productId: product.id,
      productName: product.name,
      price: product.price,
      quantity: quantity,
      // description: '', // Thêm mô tả nếu cần thiết
    );

    // Thêm sản phẩm vào danh sách chi tiết đơn hàng hiển thị trên giao diện
    setState(() {
      _orderDetails.add(orderDetail);
    });

    // Lấy reference đến document của đơn hàng hiện tại trong collection 'orders'
    // Đây là một cách để đảm bảo rằng bạn chỉ lưu dữ liệu vào đơn hàng hiện tại
    DocumentReference orderRef =
        FirebaseFirestore.instance.collection('orders').doc('carry_away');

    // Thêm chi tiết đơn hàng vào collection 'order_details' của đơn hàng hiện tại
    await orderRef.collection('order_details').doc(product.id).set({
      'product_id': product.id,
      'product_name': product.name,
      'quantity': quantity,
      'price': product.price,
    });
  }

  Widget _buildOrderDetailsColumn() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('orders')
          .doc('carry_away')
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color.fromARGB(255, 207, 205, 205),
              margin: const EdgeInsets.all(0),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Row(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hóa đơn',
                    style: TextStyle(
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
              child: Container(
                padding: const EdgeInsets.all(10),
                height: 50,
                child: Row(
                  children: [
                    const Text(
                      'Tổng giá:',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    Text(
                      '${totalAmount.toStringAsFixed(2)} VND',
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ],
                ),
              ),
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
                  Text('Giá: ${orderDetail.price} VND'),
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
                  child: const Text('Xóa'),
                  onPressed: () {
                    _removeOrderDetail(orderDetail);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Lưu'),
                  onPressed: () {
                    _updateOrderDetailQuantity(orderDetail, quantity);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Đóng'),
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
    // Cập nhật số lượng sản phẩm trong đơn hàng của bàn
    await _firestore
        .collection('orders')
        .doc('carry_away')
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

  void _removeOrderDetail(OrderDetail orderDetail) async {
    // Xóa sản phẩm khỏi đơn hàng của bàn
    await _firestore
        .collection('orders')
        .doc('carry_away')
        .collection('order_details')
        .doc(orderDetail.productId)
        .delete();
  }

  Future<void> _saveOrder() async {
    if (_orderDetails.isNotEmpty) {
      // Tạo một tài liệu đơn hàng mới với ID tự động
      DocumentReference orderRef =
          FirebaseFirestore.instance.collection('orders').doc();

      // Lưu từng chi tiết đơn hàng vào bộ sưu tập con 'order_details' của đơn hàng mới tạo
      for (var orderDetail in _orderDetails) {
        await orderRef
            .collection('order_details')
            .doc(orderDetail.productId)
            .set({
          'product_id': orderDetail.productId,
          'product_name': orderDetail.productName,
          'quantity': orderDetail.quantity,
          'price': orderDetail.price,
        });
      }

      // Xóa các chi tiết đơn hàng sau khi lưu
      setState(() {
        _orderDetails.clear();
      });
    }
  }
}
