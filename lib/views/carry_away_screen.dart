import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cake_coffee/models/khanh/category_product.dart';
import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:cake_coffee/models/khanh/oder_detail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_coffee/models/khanh/products.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Carry_Away extends StatefulWidget {
  final String nvName;
  const Carry_Away({super.key, required this.nvName});

  @override
  _Carry_AwayState createState() => _Carry_AwayState();
}

class _Carry_AwayState extends State<Carry_Away> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _phoneController = TextEditingController();
  String _point = '';
  String _nameCustomer = '';
  String _phoneCustomer = '';
  bool isAccumulatePoints = false;
  double selectedVoucherValue = 0;

  final List<OrderDetail> _orderDetails = [];
  final TextEditingController _searchProductController =
      TextEditingController();
  TextEditingController amountPaidController = TextEditingController();
  String _selectedCategoryId = '';
  List<Category> categories = [];
  bool isPay = true;
  bool isActive = false;
  bool isPendingApproval = false;
  bool _errorMessage = false;
  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
    _loadCategories();
  }

  void _getCustomerPoint(String phone) async {
    FirebaseFirestore.instance
        .collection('customers')
        .where('phone', isEqualTo: phone)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _point = querySnapshot.docs.first['point'].toString();
          _nameCustomer = querySnapshot.docs.first['name'].toString();
          _phoneCustomer = querySnapshot.docs.first['phone'].toString();
        });
      } else {
        setState(() {
          _point = 'Không tìm thấy';
          _nameCustomer = 'Không tìm thấy';
        });
      }
    }).catchError((error) {
      setState(() {
        _point = 'Error: $error';
        _nameCustomer = 'Error: $error';
      });
    });
  }

  Future<void> _updatePoint(double vourcher, String phone, double total) async {
    double point_ = double.tryParse(_point) ?? 0;
    double point = (point_ - (vourcher * 10)) + (total / 10);
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('customers')
          .where('phone', isEqualTo: phone)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        // Lấy reference của khách hàng đầu tiên trong danh sách
        DocumentReference customerRef = querySnapshot.docs.first.reference;
        // cập nhật điểm
        await customerRef.update({'point': point});
      } else {
        print('không tìm thấy khách hàng');
      }
    } catch (e) {}
  }

  void _loadCategories() async {
    List<Category> fetchedCategories = await fetchCategoriesFromFirestore();
    setState(() {
      categories = fetchedCategories;
    });
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
        setState(() {
          isPendingApproval = true;
        });
        for (var doc in snapshot.docs) {
          orderDetails.add(OrderDetail.fromFirestore(doc));
        }
      } else {
        setState(() {
          isPendingApproval = false;
        });
      }
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
            flex: 5,
            child: Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: _buildOrderDetailsColumn()),
          ),
          // Cột chứa thông tin sản phẩm đã đặt hàng
          Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey.shade100,
                child: Column(
                  children: [
                    _buildSearchAndFilter(),
                    _buildAllProductsColumn(),
                  ],
                ),
              )),
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

        // Lọc sản phẩm theo danh mục và tìm kiếm
        if (_selectedCategoryId.isNotEmpty) {
          products = products
              .where((product) =>
                  product.id_category_product == _selectedCategoryId)
              .toList();
        }
        if (_searchProductController.text.isNotEmpty) {
          products = products
              .where((product) => product.name
                  .toLowerCase()
                  .contains(_searchProductController.text.toLowerCase()))
              .toList();
        }

        return Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              Product product = products[index];
              return ListTile(
                leading: product.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.image,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                      )
                    : const Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.error),
                      ),
                title: Text(product.name),
                subtitle: Text('${product.price.toStringAsFixed(2)}đ'),
                onTap: () => _showAddQuantityDialog(product),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddQuantityDialog(Product product) {
    int quantity = 1;
    String note = '';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Thêm: ${product.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Giá: ${product.price.toStringAsFixed(2)} đ'),
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
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      hintText: 'Thêm ghi chú',
                    ),
                    onChanged: (value) {
                      setState(() {
                        note = value;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Thoát'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Thêm'),
                  onPressed: () {
                    _addToOrder(product, quantity, note);
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

  void _addToOrder(Product product, int quantity, String note) async {
    // Tạo một đối tượng OrderDetail mới để lưu thông tin sản phẩm vào đơn hàng
    OrderDetail orderDetail = OrderDetail(
      productId: product.id,
      productName: product.name,
      price: product.price,
      quantity: quantity,
      note: note, // Thêm mô tả nếu cần thiết
    );

    // Thêm sản phẩm vào danh sách chi tiết đơn hàng hiển thị trên giao diện
    setState(() {
      _orderDetails.add(orderDetail);
      isPendingApproval = true;
    });

    // Lấy reference đến document của đơn hàng hiện tại trong collection 'orders'
    // đảm bảo rằng bạn chỉ lưu dữ liệu vào đơn hàng hiện tại
    DocumentReference orderRef =
        FirebaseFirestore.instance.collection('orders').doc('carry_away');

    // Thêm chi tiết đơn hàng vào collection 'order_details' của đơn hàng hiện tại
    await orderRef.collection('order_details').doc(product.id).set({
      'product_id': product.id,
      'product_name': product.name,
      'quantity': quantity,
      'price': product.price,
      'note': note ?? ''
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
        double amountPaid = double.tryParse(amountPaidController.text) ?? 0;
        double changeAmount = selectedVoucherValue > 0
            ? (amountPaid - (totalAmount - selectedVoucherValue))
                .clamp(0, double.infinity)
            : (amountPaid - totalAmount).clamp(0, double.infinity);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: const Color.fromARGB(255, 207, 205, 205),
              margin: const EdgeInsets.all(0),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mang về',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
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
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orderDetails.length,
                      itemBuilder: (context, index) {
                        final orderDetail = orderDetails[index];
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
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('${index + 1}'),
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
                                        child: Text(
                                            '${orderDetail.price.toStringAsFixed(2)} đ'),
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
                                            '${(orderDetail.quantity * orderDetail.price).toStringAsFixed(2)} đ'),
                                      ),
                                    ),
                                  ],
                                ),
                                if (orderDetail.note != '')
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child:
                                            Text('Ghi chú:${orderDetail.note}'),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Add order_details2 here
                  ],
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              elevation: 3,
              child: Container(
                color: Colors.grey.shade300,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Row(
                      children: [Text("Thông tin")],
                    ),
                    if (isActive)
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            Expanded(
                                child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  height: 50,
                                  width:
                                      MediaQuery.of(context).size.width * 0.13,
                                  child: roundedElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isAccumulatePoints =
                                            !isAccumulatePoints;
                                        // Đảo ngược giá trị hiện tại của isAccumulatePoints
                                        if (isAccumulatePoints == false)
                                          _point = '';
                                        _nameCustomer = '';
                                        selectedVoucherValue = 0;
                                        _phoneController.clear();
                                      });
                                    },
                                    text: "Tích điểm",
                                    backgroundColor: isAccumulatePoints == true
                                        ? Colors.green.shade400
                                        : Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            )),
                            if (isAccumulatePoints)
                              Expanded(
                                child: Container(
                                  width: 200,
                                  padding: const EdgeInsets.all(5),
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Nhập số điện thoại',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      if (value.length == 10) {
                                        _getCustomerPoint(value);
                                      } else {
                                        setState(() {
                                          _point = '';
                                          _nameCustomer = '';
                                          selectedVoucherValue = 0;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            if (isAccumulatePoints)
                              Expanded(
                                child: SizedBox(
                                  child: Column(
                                    children: [
                                      Text(' $_nameCustomer'),
                                      Text('Điểm: $_point')
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(child: Container()),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: const Text("Tổng tiền"),
                          ),
                        ),
                        Expanded(
                          child: Container(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Text(
                                    "${totalAmount.toStringAsFixed(2)} đ",
                                    style: TextStyle(
                                      decoration: selectedVoucherValue > 0
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  if (selectedVoucherValue > 0)
                                    Text(
                                      "${(totalAmount - selectedVoucherValue).toStringAsFixed(2)} đ",
                                      style: const TextStyle(),
                                    ),
                                ],
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (isActive)
                      if (isAccumulatePoints)
                        Row(
                          children: [
                            Expanded(child: Container()),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: const Text("Số tiền đã giảm:"),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  height: 50,
                                  child: roundedElevatedButton(
                                    onPressed: () {
                                      _showVoucherDialog();
                                    },
                                    text: selectedVoucherValue > 0
                                        ? "${selectedVoucherValue.toStringAsFixed(2)}đ"
                                        : "Chọn voucher",
                                    backgroundColor: selectedVoucherValue > 0
                                        ? Colors.green.shade400
                                        : Colors.grey.shade400,
                                  )),
                            ),
                          ],
                        ),
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (isActive)
                                    Column(
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.only(bottom: 5),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.13,
                                          child: roundedElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  isPay = true;
                                                });
                                              },
                                              text: "Tiền mặt",
                                              backgroundColor: isPay == true
                                                  ? Colors.green.shade400
                                                  : Colors.grey.shade400),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.13,
                                          child: roundedElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  isPay = false;
                                                  _errorMessage = false;
                                                });
                                              },
                                              text: "Chuyển khoản",
                                              backgroundColor: isPay == false
                                                  ? Colors.green
                                                  : Colors.grey.shade400),
                                        ),
                                      ],
                                    ),
                                  if (isPendingApproval)
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      height: 70,
                                      child: roundedElevatedButton(
                                        onPressed: () {
                                          _showAdditionalOrderDialog();
                                        },
                                        text: "In bill",
                                        backgroundColor: Colors.red,
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ],
                        )),
                        Expanded(
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isActive)
                                  if (isPay)
                                    Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            child: const Text("Khách đưa"),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 20, 0, 0),
                                            child: const Text("Tiền thừa"),
                                          ),
                                        ],
                                      ),
                                    ),
                                Container(),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isActive)
                                  if (isPay)
                                    Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            child: TextFormField(
                                              controller: amountPaidController,
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true),
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'^\d+\.?\d{0,2}')),
                                              ],
                                              decoration: InputDecoration(
                                                hintText: 'Tiền nhận..',
                                                border:
                                                    const OutlineInputBorder(),
                                                filled: true,
                                                fillColor: Colors.grey[200],
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                ),
                                              ),
                                              validator: (value) {
                                                double? amountPaid =
                                                    double.tryParse(
                                                        value ?? '');
                                                if (amountPaid == null ||
                                                    amountPaid < totalAmount) {
                                                  return 'Số tiền nhận phải lớn hơn hoặc bằng tổng số tiền';
                                                }
                                                return null;
                                              },
                                              onChanged: (_) {
                                                setState(() {
                                                  amountPaid = double.tryParse(
                                                          amountPaidController
                                                              .text) ??
                                                      0;
                                                });
                                              },
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                                "${changeAmount.toStringAsFixed(2)} đ"),
                                          ),
                                        ],
                                      ),
                                    ),
                                Container(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            if (isActive)
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        if (_errorMessage)
                          const SizedBox(
                            child: Text(
                              "Giá nhập vào chưa hợp lê!",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        Container(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            width: MediaQuery.of(context).size.width * 0.3,
                            height: 50,
                            child: roundedElevatedButton(
                                onPressed: () {
                                  if (isPay) {
                                    if (selectedVoucherValue > 0) {
                                      if (amountPaid <
                                          (totalAmount -
                                              selectedVoucherValue)) {
                                        setState(() {
                                          _errorMessage = true;
                                        });
                                        return;
                                      } else {
                                        setState(() {
                                          _errorMessage = false;
                                        });
                                      }
                                    } else {
                                      if (amountPaid < totalAmount) {
                                        setState(() {
                                          _errorMessage = true;
                                        });
                                        return;
                                      } else {
                                        setState(() {
                                          _errorMessage = false;
                                        });
                                      }
                                    }
                                  }
                                  _showAdditionalPayDialog(
                                      amountPaid,
                                      changeAmount,
                                      totalAmount,
                                      selectedVoucherValue);
                                },
                                text: "Thanh toán",
                                backgroundColor: Colors.green.shade400))
                      ],
                    )
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  void _showVoucherDialog() {
    List<double> vouchers = [];
    double point = double.tryParse(_point) ?? 0;

    if (point >= 200) vouchers.add(20);
    if (point >= 500) vouchers.add(50);
    if (point >= 1000) vouchers.add(100);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Chọn voucher"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Không chọn voucher"),
                onTap: () {
                  setState(() {
                    selectedVoucherValue = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              ...vouchers.map((value) {
                return ListTile(
                  title: Text("Voucher ${value.toStringAsFixed(2)} đ"),
                  onTap: () {
                    setState(() {
                      selectedVoucherValue = value;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAdditionalPayDialog(double amountPaid, double changeAmount,
      double totalAmount, double vourcher) {
    List<OrderDetail> orderDetails = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Hóa đơn thanh toán"),
                ],
              ),
              const Text('Mang về'),
              Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()))
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('orders')
                  .doc('carry_away')
                  .collection('order_details')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('Không có món mới để duyệt.'));
                }

                orderDetails = snapshot.data!.docs
                    .map((doc) => OrderDetail.fromFirestore(doc))
                    .toList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 3,
                      child: Container(
                        color: const Color.fromARGB(255, 207, 205, 205),
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
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      // height: 300, // Giới hạn chiều cao
                      //child: SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: orderDetails.length,
                        itemBuilder: (context, index) {
                          final orderDetail = orderDetails[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () =>
                                  _showProductDetailDialog(orderDetail),
                              child: SizedBox(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('${index + 1}'),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Text(orderDetail.productName),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                '${orderDetail.price.toStringAsFixed(2)} đ'),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Text('${orderDetail.quantity}'),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${(orderDetail.quantity * orderDetail.price).toStringAsFixed(2)} đ',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (orderDetail.note != '')
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(orderDetail.note),
                                          ),
                                        ],
                                      )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text("Tổng hóa đơn:"),
                                  Text(
                                    "${totalAmount.toStringAsFixed(2)} đ",
                                    style: TextStyle(
                                      decoration: selectedVoucherValue > 0
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  if (selectedVoucherValue > 0)
                                    Text(
                                        "${(totalAmount - vourcher).toStringAsFixed(2)} đ"),
                                ],
                              ),
                              if (selectedVoucherValue > 0)
                                Row(
                                  children: [
                                    const Text("Giảm giá:"),
                                    Text(" ${vourcher.toStringAsFixed(2)}đ"),
                                  ],
                                ),
                              Row(
                                children: [
                                  const Text("Tổng tiền thanh toán:"),
                                  Text(
                                      "${(totalAmount - vourcher).toStringAsFixed(2)} đ"),
                                ],
                              ),
                              if (isPay)
                                const Row(
                                  children: [
                                    Text("Thanh toán tiền mặt"),
                                  ],
                                ),
                              if (isPay)
                                Row(
                                  children: [
                                    const Text("Tiền nhận:"),
                                    Text("${amountPaid.toStringAsFixed(2)} đ"),
                                  ],
                                ),
                              if (isPay)
                                Row(
                                  children: [
                                    const Text("Tiền thừa:"),
                                    Text("${changeAmount.toStringAsFixed(2)}đ"),
                                  ],
                                ),
                              if (isPay == false)
                                Row(
                                  children: [
                                    Text(
                                        "Chuyển khoản: ${(totalAmount - selectedVoucherValue).toStringAsFixed(2)}  đ"),
                                    //Text("${totalAmount.toStringAsFixed(2)} đ"),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                            child: Container(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: [
                              if (isPay == false)
                                Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Image.asset(
                                          'assets/pay.png',
                                          width: 150,
                                          height: 150,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ))
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('In hóa đơn'),
              onPressed: () async {
                Navigator.of(context).pop();
                String nextInvoiceId = await getNextInvoiceIdFromFirestore();

                await _savePayPdfToFile(
                  orderDetails,
                  nextInvoiceId,
                  totalAmount,
                  amountPaid,
                  changeAmount,
                  vourcher,
                  "142 Dương Bá Trạc,Phường 2,Quận 8,HCM",
                );
                await _saveInvoiceToFirestore(
                  orderDetails,
                  _phoneCustomer,
                  totalAmount,
                  vourcher,
                  (totalAmount - vourcher),
                  isPay == true ? amountPaid : 0.0,
                  isPay == true ? changeAmount : 0.0,
                  widget.nvName,
                  "Mang về",
                  isPay == true ? "Tiền mặt" : "Chuyển khoản",
                  "142 Dương Bá Trạc,Phường 2,Quận 8,HCM",
                );
                if (selectedVoucherValue > 0) {
                  _updatePoint(
                      vourcher, _phoneCustomer, (totalAmount - vourcher));
                }

                setState(() {
                  isAccumulatePoints = false;
                  selectedVoucherValue = 0;
                  amountPaidController.clear();
                  _phoneCustomer = "";
                });
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
  }

  Future<void> _saveInvoiceToFirestore(
    List<OrderDetail> orderDetails,
    String phoneCustomer,
    double totalBill,
    double vourcher,
    double totalAmount,
    double amountPaid,
    double changeAmount,
    String employeeName,
    String Mangve,
    String paymentMethod,
    String address,
  ) async {
    try {
      String nextInvoiceId = await getNextInvoiceIdFromFirestore();
      // Chuẩn bị danh sách chi tiết đơn hàng
      List<Map<String, dynamic>> orderDetailsData = orderDetails.map((detail) {
        return {
          'price': detail.price,
          'product_id': detail.productId,
          'product_name': detail.productName,
          'quantity': detail.quantity,
          'total_price': detail.quantity * detail.price,
          'note': detail.note
        };
      }).toList();

      // Tạo một document mới trong collection 'invoices'
      await FirebaseFirestore.instance.collection('invoices').add({
        'invoice_id': nextInvoiceId,
        'date': Timestamp.now(),
        'employee': employeeName,
        'phone_Customer': phoneCustomer,
        'order_details': orderDetailsData,
        'table_name': Mangve,
        'total_bill': totalBill,
        'total_amount': totalAmount,
        'vourcher': vourcher,
        'amount_paid': amountPaid,
        'change_amount': changeAmount,
        'payment_method': paymentMethod,
        'address': address,
      });

      print('Hóa đơn đã được lưu thành công');
    } catch (e) {
      print('Lỗi khi lưu hóa đơn: $e');
    }
  }

  Future<String> getNextInvoiceIdFromFirestore() async {
    // Đọc hóa đơn cuối cùng từ Firestore để xác định ID tiếp theo
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('invoices')
        .orderBy('invoice_id', descending: true)
        .limit(1)
        .get();

    // Nếu có hóa đơn trong Firestore
    if (querySnapshot.docs.isNotEmpty) {
      // Lấy ID của hóa đơn cuối cùng
      String lastInvoiceId = querySnapshot.docs.first['invoice_id'];
      // Chuyển đổi thành số nguyên
      int lastId = int.parse(lastInvoiceId);
      // Tăng ID lên 1 để tạo hóa đơn mới
      int nextId = lastId + 1;
      // Format lại ID để đảm bảo có 6 chữ số (ví dụ: 000001)
      String nextInvoiceId = nextId.toString().padLeft(6, '0');
      return nextInvoiceId;
    } else {
      // Nếu chưa có hóa đơn nào trong Firestore, bắt đầu từ 000001
      return '000001';
    }
  }

  void _showAdditionalOrderDialog() {
    List<OrderDetail> orderDetails2 = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mang về'),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()))
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('orders')
                    .doc('carry_away')
                    .collection('order_details')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('Không có món mới để duyệt.'));
                  }

                  orderDetails2 = snapshot.data!.docs
                      .map((doc) => OrderDetail.fromFirestore(doc))
                      .toList();
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          elevation: 3,
                          child: Container(
                            color: const Color.fromARGB(255, 207, 205, 205),
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
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 400, // Giới hạn chiều cao
                          child: SingleChildScrollView(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: orderDetails2.length,
                              itemBuilder: (context, index) {
                                final orderDetails = orderDetails2[index];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () =>
                                        _showProductDetailDialog(orderDetails),
                                    child: SizedBox(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text('${index + 1}'),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      orderDetails.productName),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      '${orderDetails.price.toStringAsFixed(2)} đ'),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      '${orderDetails.quantity}'),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '${(orderDetails.quantity * orderDetails.price).toStringAsFixed(2)} đ',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (orderDetails.note != '')
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child:
                                                      Text(orderDetails.note),
                                                ),
                                              ],
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('In hóa đơn'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _savePdfToFile(orderDetails2);
                  setState(() {
                    isPendingApproval = false;
                    isActive = true;
                  });
                },
              ),
              TextButton(
                child: const Text('Đóng'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _savePdfToFile(List<OrderDetail> orderDetails2) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Mang về',
                  style: pw.TextStyle(font: ttf, fontSize: 18),
                ),
              ),
              pw.Text(
                'Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(font: ttf),
              ),
              pw.SizedBox(height: 20),
              // Table headers
              pw.Container(
                decoration: pw.BoxDecoration(
                  //color: PdfColors.blue, // Màu nền là màu xanh
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'STT',
                        style: pw.TextStyle(
                            font: ttf, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        'Tên món',
                        style: pw.TextStyle(
                            font: ttf, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Giá',
                        // textAlign: pw.TextAlign.right, // Căn phải
                        style: pw.TextStyle(
                            font: ttf, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Số lượng',
                        // textAlign: pw.TextAlign.right, // Căn phải
                        style: pw.TextStyle(
                            font: ttf, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'Thành tiền',
                        // textAlign: pw.TextAlign.right, // Căn phải
                        style: pw.TextStyle(
                            font: ttf, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Table data
              ...orderDetails2.asMap().entries.map((entry) {
                final index = entry.key;
                final orderDetail = entry.value;
                return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.Column(children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              '${index + 1}',
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                          pw.Expanded(
                            flex: 4,
                            child: pw.Text(
                              orderDetail.productName,
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              '${orderDetail.price.toStringAsFixed(2)} đ',
                              //  textAlign: pw.TextAlign.right, // Căn phải
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              '${orderDetail.quantity}',
                              textAlign: pw.TextAlign.center, // Căn phải
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              '${(orderDetail.quantity * orderDetail.price).toStringAsFixed(2)} đ',
                              textAlign: pw.TextAlign.right, // Căn phải
                              style: pw.TextStyle(font: ttf),
                            ),
                          ),
                        ],
                      ),
                      if (orderDetail.note != '')
                        pw.Row(children: [
                          pw.Text(
                            'Mô tả: ${orderDetail.note}',
                            style: pw.TextStyle(font: ttf),
                          ),
                        ])
                    ]));
              }),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final desktopPath = Platform.isWindows
        ? 'C:/Users/DELL/OneDrive/Desktop/'
        : '${output.path}/Desktop/';

    final file = File(
        '$desktopPath${DateFormat('dd-MM-yyyy_HH-mm').format(DateTime.now())}.pdf');
    await file.writeAsBytes(await pdf.save());
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File PDF đã được lưu'),
        content: Text('Bạn có thể tìm thấy file tại: ${file.path}'),
        actions: <Widget>[
          TextButton(
            child: const Text('Đóng'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _savePayPdfToFile(
      List<OrderDetail> orderDetails,
      String invoiceId,
      double totalAmount,
      double amountPaid,
      double changeAmount,
      double vourcher,
      String address) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final Uint8List imageBytes = await loadAsset('assets/pay.png');

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Hóa Đơn Thanh Toán',
                  style: pw.TextStyle(font: ttf, fontSize: 24),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Mã hóa đơn: $invoiceId',
                  style: pw.TextStyle(font: ttf, fontSize: 18),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'Tên nhân viên: ${widget.nvName}',
                  style: pw.TextStyle(font: ttf, fontSize: 15),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'Mang về',
                  style: pw.TextStyle(font: ttf),
                ),
              ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(font: ttf),
                ),
              ),
              pw.SizedBox(height: 20),
              // Table headers
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'STT',
                        style: pw.TextStyle(
                            font: ttf, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        'Tên món',
                        style: pw.TextStyle(
                            font: ttf, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Giá',
                        style: pw.TextStyle(
                            font: ttf, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Số lượng',
                        style: pw.TextStyle(
                            font: ttf, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'Thành tiền',
                        style: pw.TextStyle(
                            font: ttf, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              // Table data
              ...orderDetails.asMap().entries.map((entry) {
                final index = entry.key;
                final orderDetail = entry.value;
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 5),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                  child: pw.Column(children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            '${index + 1}',
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text(
                            orderDetail.productName,
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            '${orderDetail.price.toStringAsFixed(2)} đ',
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            '${orderDetail.quantity}',
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            '${(orderDetail.quantity * orderDetail.price).toStringAsFixed(2)} đ',
                            style: pw.TextStyle(font: ttf),
                          ),
                        ),
                      ],
                    ),
                    if (orderDetail.note != '')
                      pw.Row(children: [
                        pw.Text(
                          'Mô tả: ${orderDetail.note}',
                          style: pw.TextStyle(font: ttf),
                        ),
                      ])
                  ]),
                );
              }),
              pw.Container(
                child: pw.Row(
                  children: [
                    pw.Text(
                      "Tổng hóa đơn:",
                      style: pw.TextStyle(font: ttf),
                    ),
                    pw.Text(
                      "${totalAmount.toStringAsFixed(2)} đ",
                      style: pw.TextStyle(
                        font: ttf,
                        decoration: selectedVoucherValue > 0
                            ? pw.TextDecoration.lineThrough
                            : pw.TextDecoration.none,
                      ),
                    ),
                    pw.SizedBox(
                      width: 10,
                    ),
                    if (selectedVoucherValue > 0)
                      pw.Text(
                          "${(totalAmount - vourcher).toStringAsFixed(2)} đ",
                          style: pw.TextStyle(font: ttf)),
                  ],
                ),
              ),
              // pw.Container(
              //   alignment: pw.Alignment.centerLeft,
              //   child: pw.Text(
              //     'Tổng tiền: ${totalAmount.toStringAsFixed(2)} đ',
              //     style: pw.TextStyle(font: ttf),
              //   ),
              // ),
              if (selectedVoucherValue > 0)
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'giảm giá: ${vourcher.toStringAsFixed(2)} đ',
                    style: pw.TextStyle(font: ttf),
                  ),
                ),
              if (isPay)
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'Tiền nhận: ${amountPaid.toStringAsFixed(2)} đ',
                    style: pw.TextStyle(font: ttf),
                  ),
                ),

              if (isPay)
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'Tiền thối: ${changeAmount.toStringAsFixed(2)} đ',
                    style: pw.TextStyle(font: ttf),
                  ),
                ),

              if (isPay == false)
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'Chuyển khoản: ${(totalAmount - vourcher).toStringAsFixed(2)} đ',
                    style: pw.TextStyle(font: ttf),
                  ),
                ),
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'Địa chỉ: $address',
                  style: pw.TextStyle(font: ttf),
                ),
              ),
              if (isPay == false)
                pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Image(
                    pw.MemoryImage(imageBytes),
                    width: 150,
                    height: 150,
                  ),
                ),
            ],
          );
        },
      ),
    );
    // final output = await getTemporaryDirectory();
    // final file = File(
    //     '${output.path}/${DateFormat('dd-MM-yyyy_HH-mm').format(DateTime.now())}.pdf');
    // await file.writeAsBytes(await pdf.save());
    final output = await getTemporaryDirectory();
    final desktopPath = Platform.isWindows
        ? 'C:/Users/DELL/OneDrive/Desktop/'
        : '${output.path}/Desktop/';

    final file = File(
        '$desktopPath${DateFormat('dd-MM-yyyy_HH-mm').format(DateTime.now())}.pdf');
    await file.writeAsBytes(await pdf.save());

    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File PDF đã được lưu'),
        content: Text('Bạn có thể tìm thấy file tại: ${file.path}'),
        actions: <Widget>[
          TextButton(
            child: const Text('Đóng'),
            onPressed: () {
              deleteOrderDetails('carry_away');
              // _firestore
              //     .collection('tables')
              //     .doc(_selectedTable!.id)
              //     .update({'status': 'empty'});
              setState(() {
                isActive = false;
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void deleteOrderDetails(String orderId) async {
    try {
      // Query collection 'order_details' của document orderId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .collection('order_details')
          .get();

      // Duyệt qua từng document và xóa
      for (DocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print('Đã xóa các order_details từ document $orderId thành công');
    } catch (e) {
      print('Lỗi khi xóa order_details: $e');
    }
  }

  Widget _buildSearchAndFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: 300,
                child: DropdownButtonFormField<String>(
                  value: _selectedCategoryId.isEmpty ? '' : _selectedCategoryId,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategoryId = newValue ?? '';
                    });
                  },
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Tất cả'),
                    ),
                    ...categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: 300,
                child: TextFormField(
                  controller: _searchProductController,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'Tìm kiếm sản phẩm',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  _searchProductController.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showProductDetailDialog(OrderDetail orderDetail) {
    int quantity = orderDetail.quantity;
    TextEditingController noteController =
        TextEditingController(text: orderDetail.note);
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
                  Text('Giá: ${orderDetail.price.toStringAsFixed(2)} đ'),
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
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      hintText: 'Thêm ghi chú',
                    ),
                    controller: noteController,
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
                    _updateOrderDetailQuantity(
                        orderDetail, quantity, noteController.text);
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
      OrderDetail orderDetail, int newQuantity, String newNote) async {
    // Cập nhật số lượng sản phẩm trong đơn hàng của bàn
    await _firestore
        .collection('orders')
        .doc('carry_away')
        .collection('order_details')
        .doc(orderDetail.productId)
        .update({'quantity': newQuantity, 'note': newNote});

    for (var detail in _orderDetails) {
      if (detail.productId == orderDetail.productId) {
        detail.quantity = newQuantity;
      }
    }
    QuerySnapshot querySnapshot = await _firestore
        .collection('orders')
        .doc('carry_away')
        .collection('order_details')
        .get();
    int itemCount = querySnapshot.docs.length;
    setState(() {
      isPendingApproval = itemCount > 0; // Set pending approval state
    });
  }

  void _removeOrderDetail(OrderDetail orderDetail) async {
    // Xóa sản phẩm khỏi đơn hàng của bàn
    await _firestore
        .collection('orders')
        .doc('carry_away')
        .collection('order_details')
        .doc(orderDetail.productId)
        .delete();

    QuerySnapshot querySnapshot = await _firestore
        .collection('orders')
        .doc('carry_away')
        .collection('order_details')
        .get();
    int itemCount = querySnapshot.docs.length;
    setState(() {
      isPendingApproval = itemCount > 0; // Set pending approval state
    });
  }

  Future<Uint8List> loadAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }
}
