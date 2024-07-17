import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cake_coffee/models/khanh/category_product.dart';
import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:cake_coffee/models/khanh/oder_detail.dart';
import 'package:cake_coffee/views/customner_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_coffee/models/khanh/products.dart';
import 'package:cake_coffee/models/khanh/table.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

class Demo extends StatefulWidget {
  final String nvName;
  const Demo({super.key, required this.nvName});

  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _tableNameController = TextEditingController();
  String _point = '';
  String idtable = '';
  String status = '';
  String status2 = '';
  String _nameTable = '';
  String _nameCustomer = '';
  String _phoneCustomer = '';
  bool isAccumulatePoints = false;
  double selectedVoucherValue = 0;
  String? _selectedTableId; // Biến để lưu trữ ID của bàn được chọn
  List<OrderDetail> _orderDetails = [];
  Tables? _selectedTable;
  bool isPendingApproval = false;
  bool isCallMore = false;
  bool isActive = false;
  bool isPay = true;
  bool accumulate_points = false;
  String selectAddProduct = '';
  String selectMoreAddProduct = '';
  Color _backgroundColor = Colors.orange.shade400;
  Timer? _timer;
  //bool isConfirm = false;
  final int _selectedIndex = 0;
  TextEditingController amountPaidController = TextEditingController();
  final TextEditingController _searchProductController =
      TextEditingController();
  String _selectedCategoryId = '';
  List<Category> categories = [];
  bool _errorMessage = false;

  List<List<String>> _draggedTableGroups = [];
  @override
  void initState() {
    super.initState();
    _loadCategories(); // Hàm để tải danh mục từ Firestore
    _startColorChange();
    _checkTableStatus();
    _loadDraggedTableGroups();
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

  void _getTables(String name, StateSetter setState) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tables')
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          idtable = querySnapshot.docs.first.id;
          _nameTable = querySnapshot.docs.first['name'].toString();
          status = querySnapshot.docs.first['status'].toString();
        });
      } else {
        setState(() {
          _nameTable = 'Không tìm thấy';
          idtable = '';
          status = '';
        });
      }
    } catch (error) {
      setState(() {
        _nameTable = 'Error: $error';
        idtable = '';
        status = '';
      });
    }
  }

  Future<void> _updatePoint(double vourcher, String phone, double total) async {
    double point_ = double.tryParse(_point) ?? 0; //0

    double point = (total / 10000) + (point_ - (vourcher / 100));

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
        setState(() {
          accumulate_points = false;
        });
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

  void _checkTableStatus() {
    _firestore.collection('tables').snapshots().listen((snapshot) {
      if (_selectedTable == null) {
        return; // Nếu chưa chọn bàn nào, không thực hiện kiểm tra
      }
      bool pendingApprovalFound = false;
      bool isAddMore = false; // Biến để kiểm tra trạng thái là "Gọi thêm"

      for (var doc in snapshot.docs) {
        if (doc['status'] == 'Chờ duyệt' && doc.id == _selectedTable!.id) {
          pendingApprovalFound = true;
        }
        if (doc['status'] == 'Gọi thêm' && doc.id == _selectedTable!.id) {
          isAddMore = true;
        }
      }

      setState(() {
        isPendingApproval = pendingApprovalFound;
        isCallMore =
            isAddMore; // Cập nhật giá trị printinvoice khi là "Gọi thêm"
        if (isCallMore == true) isActive = false;
      });
    });
  }

  @override
  void dispose() {
    _searchProductController.dispose();
    amountPaidController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startColorChange() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _backgroundColor = _backgroundColor == Colors.orange.shade400
            ? Colors.yellow.shade400
            : Colors.orange.shade400;
      });
    });
  }

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
                      List<Tables> addproduct = tables
                          .where((table) => table.status == 'Gọi thêm')
                          .toList();
                      List<Tables> activeTables = tables
                          .where((table) => table.status == 'Đang hoạt động')
                          .toList();
                      List<Tables> pendingApprovalTables = tables
                          .where((table) => table.status == 'Chờ duyệt')
                          .toList();
                      List<Tables> emptyTables = tables
                          .where((table) => table.status == 'Trống')
                          .toList();
                      List<Tables> combinedActiveTables =
                          activeTables + addproduct;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTableList2(
                              'Đang hoạt động', combinedActiveTables),
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
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: _buildOrderDetailsColumn())
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: const Center(
                            child: Text('Chọn 1 bàn'),
                          ),
                        ),
                ])),
            // Cột chứa danh sách sản phẩm
            Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey.shade100,
                  child: Column(
                    children: [
                      _buildSearchAndFilter(),
                      _buildAllProductsColumn(),
                      Container(
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                        child: roundedElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CustomerScreen()),
                            );
                          },
                          text: "Khách hàng thành viên",
                          backgroundColor: Colors.green.shade300,
                        ),
                      )
                    ],
                  ),
                )),
          ],
        ),
        Container(
          child: const Text('hahah'),
        )
      ],
    ));
  }

  void _showMergeTableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isMerging = false; //
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Gộp bàn'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 200,
                    padding: const EdgeInsets.all(5),
                    child: TextFormField(
                      controller: _tableNameController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Nhập tên bàn',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _getTables(value, setState);
                        } else {
                          setState(() {
                            idtable = '';
                            _nameTable = '';
                            status = '';
                          });
                        }
                      },
                    ),
                  ),
                  if (_nameTable.isNotEmpty &&
                      idtable.isNotEmpty &&
                      status.isNotEmpty)
                    SizedBox(
                      child: Column(
                        children: [
                          Text(' Bàn $_nameTable'),
                          // Text('Mã: ${_selectedTable!.name}'),
                          Text('Trạng thái: $status')
                        ],
                      ),
                    ),
                ],
              ),
              actions: [
                if (!isMerging) // Ẩn nút Hủy khi đang gộp
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Hủy'),
                  ),
                ElevatedButton(
                  onPressed: !isMerging
                      ? () async {
                          setState(() {
                            isMerging = true; // Bắt đầu quá trình gộp
                          });
                          String tableName = _tableNameController.text;
                          _mergeTable(tableName);

                          if (mounted) {
                            //mounted là một thuộc tính của State class,
                            //dùng để kiểm tra xem State object có được "gắn" vào cây widget hay không.
                            setState(() {
                              isMerging = false; // Kết thúc quá trình gộp
                            });
                            Navigator.pop(context);
                          }
                        }
                      : null,
                  child: const Text('Chọn gộp'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _mergeTable(String tableName) async {
    if (idtable.isNotEmpty) {
      if (_selectedTable!.name != _nameTable) {
        if (_selectedTable!.status == 'Trống' && status == 'Trống') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không có món để gộp.'),
            ),
          );
          return;
        }

        if (_selectedTable!.status == 'Gọi thêm' || status == 'Gọi thêm') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Vui lòng duyệt(hoặc xóa) món thêm trước khi gộp bàn!.'),
            ),
          );
          return;
        }

        try {
          // Merge logic when _selectedTable.status == 'Đang hoạt động' and status == 'Chờ duyệt'
          if (_selectedTable!.status == 'Đang hoạt động' &&
              status == 'Chờ duyệt') {
            var snapshot = await _firestore
                .collection('orders')
                .doc(idtable)
                .collection('order_details')
                .get();

            for (var doc in snapshot.docs) {
              var product = OrderDetail.fromFirestore(doc);
              await _firestore
                  .collection('orders')
                  .doc(_selectedTable!.id)
                  .collection('order_details2')
                  .doc(product.productId)
                  .set({
                'product_id': product.productId,
                'product_name': product.productName,
                'quantity': product.quantity,
                'price': product.price,
                'note': product.note ?? '',
              });

              await doc.reference.delete();
            }

            await _firestore.collection('tables').doc(idtable).update({
              'status': 'Trống',
            });

            if (mounted) {
              setState(() async {
                await _firestore
                    .collection('tables')
                    .doc(_selectedTable!.id)
                    .update({
                  'status': 'Gọi thêm',
                });
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gộp thành công.'),
              ),
            );
            return;
          }

          // Merge logic when _selectedTable.status == 'Chờ duyệt' and status == 'Đang hoạt động'
          if (_selectedTable!.status == 'Chờ duyệt' &&
              status == 'Đang hoạt động') {
            var snapshot = await _firestore
                .collection('orders')
                .doc(_selectedTable!.id)
                .collection('order_details')
                .get();

            for (var doc in snapshot.docs) {
              var product = OrderDetail.fromFirestore(doc);
              await _firestore
                  .collection('orders')
                  .doc(_selectedTable!.id)
                  .collection('order_details2')
                  .doc(product.productId)
                  .set({
                'product_id': product.productId,
                'product_name': product.productName,
                'quantity': product.quantity,
                'price': product.price,
                'note': product.note ?? '',
              });

              await doc.reference.delete();
            }

            var snapshots = await _firestore
                .collection('orders')
                .doc(idtable)
                .collection('order_details')
                .get();
            for (var doc in snapshots.docs) {
              var products = OrderDetail.fromFirestore(doc);
              await _firestore
                  .collection('orders')
                  .doc(_selectedTable!.id)
                  .collection('order_details')
                  .doc(products.productId)
                  .set({
                'product_id': products.productId,
                'product_name': products.productName,
                'quantity': products.quantity,
                'price': products.price,
                'note': products.note ?? '',
              });

              await doc.reference.delete();
            }

            await _firestore.collection('tables').doc(idtable).update({
              'status': 'Trống',
            });

            if (mounted) {
              setState(() async {
                await _firestore
                    .collection('tables')
                    .doc(_selectedTable!.id)
                    .update({
                  'status': 'Gọi thêm',
                });
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gộp thành công.'),
              ),
            );
            return;
          }

          // Merge logic for general case
          var snapshot = await _firestore
              .collection('orders')
              .doc(idtable)
              .collection('order_details')
              .get();

          for (var doc in snapshot.docs) {
            var product = OrderDetail.fromFirestore(doc);

            var existingProductDoc = await _firestore
                .collection('orders')
                .doc(_selectedTable!.id)
                .collection('order_details')
                .doc(product.productId)
                .get();

            if (existingProductDoc.exists) {
              int currentQuantity = existingProductDoc.data()!['quantity'] ?? 0;
              await _firestore
                  .collection('orders')
                  .doc(_selectedTable!.id)
                  .collection('order_details')
                  .doc(product.productId)
                  .update({
                'quantity': currentQuantity + product.quantity,
              });
            } else {
              await _firestore
                  .collection('orders')
                  .doc(_selectedTable!.id)
                  .collection('order_details')
                  .doc(product.productId)
                  .set({
                'product_id': product.productId,
                'product_name': product.productName,
                'quantity': product.quantity,
                'price': product.price,
                'note': product.note ?? '',
              });
            }

            await doc.reference.delete();
          }

          setState(() {
            // Tìm và tách bàn từ các nhóm kéo hiện tại
            for (var group in _draggedTableGroups) {
              if (group.contains(tableName)) {
                group.remove(tableName);
                break; // Đảm bảo chỉ tách một bàn duy nhất
              }
            }

            // Loại bỏ các nhóm không có bàn sau khi tách
            _draggedTableGroups.removeWhere((group) => group.length == 1);
          });

          await _firestore.collection('tables').doc(idtable).update({
            'status': 'Trống',
          });

          if (_selectedTable!.status == 'Chờ duyệt' && status == 'Trống') {
            await _firestore
                .collection('tables')
                .doc(_selectedTable!.id)
                .update({
              'status': 'Chờ duyệt',
            });
          } else if (_selectedTable!.status == 'Trống' &&
              status == 'Chờ duyệt') {
            await _firestore
                .collection('tables')
                .doc(_selectedTable!.id)
                .update({
              'status': 'Chờ duyệt',
            });
          } else if (_selectedTable!.status == 'Đang hoạt động' &&
              status == 'Trống') {
            await _firestore
                .collection('tables')
                .doc(_selectedTable!.id)
                .update({
              'status': 'Đang hoạt động',
            });
          } else if (_selectedTable!.status == 'Trống' &&
              status == 'Đang hoạt động') {
            await _firestore
                .collection('tables')
                .doc(_selectedTable!.id)
                .update({
              'status': 'Đang hoạt động',
            });
          }

          if (mounted) {
            setState(() {
              _nameTable = '';
              idtable = '';
              status = '';
              _tableNameController.clear();
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gộp thành công.'),
            ),
          );
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra trong quá trình gộp.'),
            ),
          );

          if (mounted) {
            setState(() {
              _nameTable = '';
              idtable = '';
              status = '';
              _tableNameController.clear();
            });
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tên bàn trùng nhau!.'),
          ),
        );
      }
    }
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
              child: Row(
                children: [
                  Expanded(child: Container()),
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bàn: ${_selectedTable!.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )),
                  Expanded(
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Row(
                            children: [
                              // if (isActive || isPendingApproval)
                              roundedElevatedButton(
                                  onPressed: _showMergeTableDialog,
                                  text: "Gộp bàn",
                                  backgroundColor: Colors.red.shade400),
                            ],
                          )))
                ],
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              elevation: 3,
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
                              onTap: () =>
                                  _showProductDetailDialog(orderDetail),
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
                                              '${FormartPrice(price: orderDetail.price)} '),
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
                                              '${FormartPrice(price: (orderDetail.quantity * orderDetail.price))} '),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (orderDetail.note != '')
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              'Ghi chú:${orderDetail.note}'),
                                        ),
                                      ],
                                    )
                                ],
                              )),
                        );
                      },
                    ),
                    // Add order_details2 here
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('orders')
                          .doc(_selectedTable!.id)
                          .collection('order_details2')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Container();
                        List<OrderDetail> orderDetails2 = snapshot.data!.docs
                            .map((doc) => OrderDetail.fromFirestore(doc))
                            .toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: orderDetails2.length,
                          itemBuilder: (context, index) {
                            final orderDetail = orderDetails2[index];
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
                                    _showProduct2DetailDialog(orderDetail),
                                child: Container(
                                    color: Colors.amber,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    '${index + orderDetails.length + 1}'),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    orderDetail.productName),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    '${FormartPrice(price: orderDetail.price)} '),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    '${orderDetail.quantity}'),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    '${(FormartPrice(price: orderDetail.quantity * orderDetail.price))} '),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (orderDetail.note != "")
                                          Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                    'Ghi chú:${orderDetail.note}'),
                                              ),
                                            ],
                                          )
                                      ],
                                    )),
                              ),
                            );
                          },
                        );
                      },
                    ),
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
                      children: [
                        Expanded(child: Text("Thông tin")),
                      ],
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
                                        setState(() {
                                          accumulate_points = true;
                                        });
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
                            child: const Text("Tổng tiền:"),
                          ),
                        ),
                        Expanded(
                          child: Container(
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Text(
                                    "${FormartPrice(price: totalAmount)} ",
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
                                      "${FormartPrice(price: (totalAmount - selectedVoucherValue))} ",
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
                                        ? FormartPrice(
                                            price: selectedVoucherValue)
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
                                  if (isCallMore)
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        height: 70,
                                        child: roundedElevatedButton(
                                          onPressed: () {
                                            _showAdditionalmoreOrderDialog();

                                            selectMoreAddProduct = '';
                                          },
                                          text: selectMoreAddProduct ==
                                                  _selectedTable!.id.toString()
                                              ? "Lưu thêm món"
                                              : "Duyệt gọi thêm",
                                          backgroundColor: Colors.red,
                                        )),
                                  if (isPendingApproval)
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      height: 70,
                                      child: roundedElevatedButton(
                                        onPressed: () {
                                          _showAdditionalOrderDialog();

                                          selectAddProduct = '';
                                        },
                                        text: selectAddProduct ==
                                                _selectedTable!.id
                                                    .toString() //?
                                            // addproduct == true
                                            ? "Lưu đơn"
                                            : "Duyệt đơn",
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
                                            child: const Text("Khách đưa:"),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                5, 20, 0, 0),
                                            child: const Text("Tiền thừa:"),
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
                                                controller:
                                                    amountPaidController,
                                                keyboardType:
                                                    const TextInputType
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
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 10,
                                                  ),
                                                ),
                                                validator: (value) {
                                                  double? amountPaid =
                                                      double.tryParse(
                                                          value ?? '');
                                                  if (amountPaid == null ||
                                                      amountPaid <
                                                          totalAmount) {
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
                                                }),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                                "${FormartPrice(price: changeAmount)} "),
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
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                          child: Row(
                            children: [
                              if (isActive)
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          if (isPay)
                                            if (_errorMessage)
                                              const SizedBox(
                                                child: Text(
                                                  "Giá nhập vào chưa hợp lê!",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                          Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 5, 0, 10),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.12,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                              child: roundedElevatedButton(
                                                  onPressed: () {
                                                    if (isPay) {
                                                      if (selectedVoucherValue >
                                                          0) {
                                                        if (amountPaid <
                                                            (totalAmount -
                                                                selectedVoucherValue)) {
                                                          setState(() {
                                                            _errorMessage =
                                                                true;
                                                          });
                                                          return;
                                                        } else {
                                                          setState(() {
                                                            _errorMessage =
                                                                false;
                                                          });
                                                        }
                                                      } else {
                                                        if (amountPaid <
                                                            totalAmount) {
                                                          setState(() {
                                                            _errorMessage =
                                                                true;
                                                          });
                                                          return;
                                                        } else {
                                                          setState(() {
                                                            _errorMessage =
                                                                false;
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
                                                  backgroundColor:
                                                      Colors.green.shade400))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        )),
                        Expanded(
                            child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  width:
                                      MediaQuery.of(context).size.width * 0.13,
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  child: roundedElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isPay = true;
                                      });
                                    },
                                    text: "Tiền mặt",
                                    backgroundColor: isPay == true
                                        ? Colors.green.shade400
                                        : Colors.grey.shade400,
                                  ),
                                ),
                            ],
                          ),
                        )),
                        Expanded(
                            child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  width:
                                      MediaQuery.of(context).size.width * 0.13,
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  child: roundedElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isPay = false;
                                      });
                                    },
                                    text: "Chuyển khoản",
                                    backgroundColor: isPay == false
                                        ? Colors.green
                                        : Colors.grey.shade400,
                                  ),
                                ),
                            ],
                          ),
                        ))
                      ],
                    )
                  ],
                ),
              ),
            ),
            // if (isActive)
            //   Container(
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Column(
            //           children: [
            //             if (isPay)
            //               if (_errorMessage)
            //                 const SizedBox(
            //                   child: Text(
            //                     "Giá nhập vào chưa hợp lê!",
            //                     style: TextStyle(color: Colors.red),
            //                   ),
            //                 ),
            //             Container(
            //                 padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
            //                 width: MediaQuery.of(context).size.width * 0.3,
            //                 height: 50,
            //                 child: roundedElevatedButton(
            //                     onPressed: () {
            //                       if (isPay) {
            //                         if (selectedVoucherValue > 0) {
            //                           if (amountPaid <
            //                               (totalAmount -
            //                                   selectedVoucherValue)) {
            //                             setState(() {
            //                               _errorMessage = true;
            //                             });
            //                             return;
            //                           } else {
            //                             setState(() {
            //                               _errorMessage = false;
            //                             });
            //                           }
            //                         } else {
            //                           if (amountPaid < totalAmount) {
            //                             setState(() {
            //                               _errorMessage = true;
            //                             });
            //                             return;
            //                           } else {
            //                             setState(() {
            //                               _errorMessage = false;
            //                             });
            //                           }
            //                         }
            //                       }
            //                       _showAdditionalPayDialog(
            //                           amountPaid,
            //                           changeAmount,
            //                           totalAmount,
            //                           selectedVoucherValue);
            //                     },
            //                     text: "Thanh toán",
            //                     backgroundColor: Colors.green.shade400))
            //           ],
            //         )
            //       ],
            //     ),
            //   ),
          ],
        );
      },
    );
  }

  void _showVoucherDialog() {
    List<double> vouchers = [];
    double point = double.tryParse(_point) ?? 0;

    if (point >= 200) vouchers.add(20000);
    if (point >= 500) vouchers.add(50000);
    if (point >= 1000) vouchers.add(100000);

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
                  title: Text("Voucher ${FormartPrice(price: value)} "),
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
              Text('Bàn: ${_selectedTable!.name}'),
              Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()))
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('orders')
                  .doc(_selectedTable!.id)
                  .collection('order_details')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                                                '${FormartPrice(price: orderDetail.price)} '),
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
                                              '${FormartPrice(price: (orderDetail.quantity * orderDetail.price))}đ',
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
                                            child: Text(
                                                'Mô tả: ${orderDetail.note}'),
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
                                        "${FormartPrice(price: (totalAmount - vourcher))} "),
                                ],
                              ),
                              if (selectedVoucherValue > 0)
                                Row(
                                  children: [
                                    const Text("Giảm giá:"),
                                    Text(" ${FormartPrice(price: vourcher)}đ"),
                                  ],
                                ),
                              Row(
                                children: [
                                  const Text("Tổng tiền thanh toán:"),
                                  Text(
                                      "${FormartPrice(price: (totalAmount - vourcher))} đ"),
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
                                    Text(
                                        "${FormartPrice(price: amountPaid)} đ"),
                                  ],
                                ),
                              if (isPay)
                                Row(
                                  children: [
                                    const Text("Tiền thừa:"),
                                    Text(
                                        "${FormartPrice(price: changeAmount)}đ"),
                                  ],
                                ),
                              if (isPay == false)
                                Row(
                                  children: [
                                    Text(
                                        "Chuyển khoản: ${FormartPrice(price: (totalAmount - selectedVoucherValue))}  đ"),
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
                  _selectedTable!.name,
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
                  _selectedTable!.name,
                  isPay == true ? "Tiền mặt" : "Chuyển khoản",
                  "142 Dương Bá Trạc,Phường 2,Quận 8,HCM",
                );
                if (accumulate_points) {
                  _updatePoint(
                      vourcher, _phoneCustomer, (totalAmount - vourcher));
                }

                setState(() {
                  isAccumulatePoints = false;
                  selectedVoucherValue = 0;
                  amountPaidController.clear();
                  _phoneCustomer = "";
                  _point = '';

                  // Tìm và tách bàn từ các nhóm kéo hiện tại
                  for (var group in _draggedTableGroups) {
                    if (group.contains(_selectedTable!.name)) {
                      group.remove(_selectedTable!.name);
                      break; // Đảm bảo chỉ tách một bàn duy nhất
                    }
                  }

                  // Loại bỏ các nhóm không có bàn sau khi tách
                  _draggedTableGroups.removeWhere((group) => group.length == 1);
                });
                deleteOrderDetails(_selectedTable!.id);
                _firestore
                    .collection('tables')
                    .doc(_selectedTable!.id)
                    .update({'status': 'Trống'});
                // setState(() {
                //   isActive = false;
                // });
                isActive = false;
                // await _firestore.collection('tables').doc(idtable).update({
                //   'status': 'Trống',
                //});
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

  Future<void> _saveInvoiceToFirestore(
    List<OrderDetail> orderDetails,
    String phoneCustomer,
    double totalBill,
    double vourcher,
    double totalAmount,
    double amountPaid,
    double changeAmount,
    String employeeName,
    String tableName,
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
        'table_name': tableName,
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

  Future<void> _savePayPdfToFile(
      List<OrderDetail> orderDetails,
      String tableName,
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
                  'Bàn: $tableName',
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
                            '${FormartPrice(price: orderDetail.price)} ',
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
                            '${FormartPrice(price: (orderDetail.quantity * orderDetail.price))} ',
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
                      "${FormartPrice(price: totalAmount)} ",
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
                          "${FormartPrice(price: (totalAmount - vourcher))} ",
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
                    'giảm giá: ${FormartPrice(price: vourcher)} ',
                    style: pw.TextStyle(font: ttf),
                  ),
                ),
              if (isPay)
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'Tiền nhận: ${FormartPrice(price: amountPaid)} ',
                    style: pw.TextStyle(font: ttf),
                  ),
                ),

              if (isPay)
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'Tiền thối: ${FormartPrice(price: changeAmount)} ',
                    style: pw.TextStyle(font: ttf),
                  ),
                ),

              if (isPay == false)
                pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'Chuyển khoản: ${FormartPrice(price: (totalAmount - vourcher))} ',
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
        title: const Text('Hóa đơn đã được lưu'),
        content: Text('Xem hóa đơn tại  tại: ${file.path}'),
        actions: <Widget>[
          TextButton(
            child: const Text('Đóng'),
            onPressed: () {
              // deleteOrderDetails(_selectedTable!.id);
              // _firestore
              //     .collection('tables')
              //     .doc(_selectedTable!.id)
              //     .update({'status': 'Trống'});
              // setState(() {
              //   isActive = false;
              // });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
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
                Text('Bàn: ${_selectedTable!.name}'),
                // const Text('Bill đã duyệt'),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()))
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('orders')
                    .doc(_selectedTable!.id)
                    .collection('order_details')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                                                      '${FormartPrice(price: orderDetails.price)} '),
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
                                                    '${FormartPrice(price: (orderDetails.quantity * orderDetails.price))} ',
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
                                                  child: Text(
                                                      'Mô tả: ${orderDetails.note}'),
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
                  _savePdfToFile(orderDetails2, _selectedTable!.name);
                  setState(() {
                    _selectedTable!.status = 'Đang hoạt động';

                    isActive = true;

                    isPendingApproval = false;
                  });
                  _firestore
                      .collection('tables')
                      .doc(_selectedTable!.id)
                      .update({'status': 'Đang hoạt động'});
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

  void _showAdditionalmoreOrderDialog() {
    List<OrderDetail> orderDetails2 = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gọi thêm'),
                Text('Bàn: ${_selectedTable!.name}'),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()))
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('orders')
                    .doc(_selectedTable!.id)
                    .collection('order_details2')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                                return SingleChildScrollView(
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 3,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => _showProduct2DetailDialog(
                                          orderDetails),
                                      child: SizedBox(
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text('${index + 1}'),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(orderDetails
                                                        .productName),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        '${FormartPrice(price: orderDetails.price)} '),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        '${orderDetails.quantity}'),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      '${FormartPrice(price: (orderDetails.quantity * orderDetails.price))} ',
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        'Mô tả: ${orderDetails.note}'),
                                                  ),
                                                ],
                                              )
                                          ],
                                        ),
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
                  _savemorePdfToFile(orderDetails2, _selectedTable!.name);
                  setState(() {
                    isCallMore = false;

                    _selectedTable!.status = 'Đang hoạt động';
                    isPendingApproval = false;

                    isActive = true;
                  });
                  _firestore
                      .collection('tables')
                      .doc(_selectedTable!.id)
                      .update({'status': 'Đang hoạt động'});

                  // Gộp order_details2 vào order_details và xóa order_details2
                  _mergeOrderDetails();
                },
              ),
              //  onPressed: () async {
              //                   setState(() {
              //                     _selectedTable!.status = 'Đang hoạt động';
              //                     isPendingApproval = false;
              //                     isCallMore = false;
              //                     isActive = true;
              //                   });
              //                   try {
              //                     // Cập nhật trạng thái bàn
              //                     await _firestore
              //                         .collection('tables')
              //                         .doc(_selectedTable!.id)
              //                         .update({'status': 'Đang hoạt động'});

              //                     // Gộp order_details2 vào order_details và xóa order_details2
              //                     _mergeOrderDetails();

              //                     Navigator.of(context)
              //                         .pop(); // Đóng hộp thoại
              //                   } catch (e) {
              //                     print(
              //                         'Error updating table status or merging order details: $e');
              //                     // Xử lý lỗi nếu cần
              //                   }
              //                 },
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

  Future<void> _savePdfToFile(
      List<OrderDetail> orderDetails2, String aaaa) async {
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
                  'Bàn: $aaaa',
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
                              '${FormartPrice(price: orderDetail.price)} ',
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
                              '${FormartPrice(price: (orderDetail.quantity * orderDetail.price))} ',
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
        title: const Text('Bill món đã được lưu'),
        content: Text('Xem nơi lưu tại: ${file.path}'),
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

  Future<void> _savemorePdfToFile(
      List<OrderDetail> orderDetails2, String nameTable) async {
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
                  'Gọi thêm',
                  style: pw.TextStyle(font: ttf, fontSize: 18),
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Text(
                'Bàn: $nameTable', // Replace with your table name
                style: pw.TextStyle(font: ttf),
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
                              '${FormartPrice(price: orderDetail.price)} ',
                              //  textAlign: pw.TextAlign.right, // Căn phải
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
                              '${FormartPrice(price: (orderDetail.quantity * orderDetail.price))} ',
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
        title: const Text('Bill món thêm đã được lưu'),
        content: Text('Xem nơi lưu tại: ${file.path}'),
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

  void _mergeOrderDetails() async {
    if (_selectedTable != null) {
      try {
        // Lấy tất cả các tài liệu từ order_details2
        var snapshot = await _firestore
            .collection('orders')
            .doc(_selectedTable!.id)
            .collection('order_details2')
            .get();

        // Duyệt qua từng tài liệu trong order_details2
        for (var doc in snapshot.docs) {
          var product =
              OrderDetail.fromFirestore(doc); // Giả sử có mô hình OrderDetail

          // Kiểm tra xem sản phẩm đã tồn tại trong order_details chưa
          var existingProductDoc = await _firestore
              .collection('orders')
              .doc(_selectedTable!.id)
              .collection('order_details')
              .doc(product.productId)
              .get();

          if (existingProductDoc.exists) {
            // Sản phẩm đã tồn tại, cập nhật số lượng
            int currentQuantity = existingProductDoc.data()!['quantity'];
            await _firestore
                .collection('orders')
                .doc(_selectedTable!.id)
                .collection('order_details')
                .doc(product.productId)
                .update({
              'quantity': currentQuantity + product.quantity,
            });
          } else {
            // Sản phẩm chưa tồn tại, thêm vào order_details
            await _firestore
                .collection('orders')
                .doc(_selectedTable!.id)
                .collection('order_details')
                .doc(product.productId)
                .set({
              'product_id': product.productId,
              'product_name': product.productName,
              'quantity': product.quantity,
              'price': product.price,
              'note': product.note ?? '', // Đảm bảo có mô tả được thêm vào
            });
          }

          // Xóa tài liệu từ order_details2 sau khi gộp
          await doc.reference.delete();
        }

        // Cập nhật trạng thái bàn sau khi gộp
        // await _updateTableStatus(_selectedTable!.id);
      } catch (e) {
        print('Lỗi khi gộp order_details2: $e');
      }
    }
  }

  void _add2ToOrder(Product product, int quantity, String note) async {
    if (_selectedTable != null) {
      try {
        // Add product to the order_details2 collection
        await _firestore
            .collection('orders')
            .doc(_selectedTable!.id)
            .collection('order_details2')
            .doc(product.id)
            .set({
          'product_id': product.id,
          'product_name': product.name,
          'quantity': quantity,
          'price': product.price,
          'note': note ?? '', // Ensure description is added
        });
        setState(() {
          isCallMore = true;
          isActive = false;
          selectMoreAddProduct = _selectedTable!.id;
        });
        await _firestore
            .collection('tables')
            .doc(_selectedTable!.id)
            .update({'status': 'Gọi thêm'});

        print('Bàn gọi thêm${_selectedTable!.id}');
        print('Sao chép bàn gọi thêm$selectMoreAddProduct');
      } catch (e) {
        print('Error adding to order_details2: $e');
      }
    }
  }

  void _update2OrderDetailQuantity(
      OrderDetail orderDetail, int newQuantity, String newNote) async {
    if (_selectedTable != null) {
      try {
        // Update quantity of a product in the order_details collection
        await _firestore
            .collection('orders')
            .doc(_selectedTable!.id)
            .collection('order_details2')
            .doc(orderDetail.productId)
            .update({'quantity': newQuantity, 'note': newNote});

        // Update local state if needed
        setState(() {
          for (var detail in _orderDetails) {
            if (detail.productId == orderDetail.productId) {
              detail.quantity = newQuantity;
              break; // Exit loop once found and updated
            }
          }
        });

        // Update table status after updating quantity
        //  await _update2TableStatus(_selectedTable!.id);
      } catch (e) {
        print('Error updating order detail quantity: $e');
      }
    }
  }

  void _updateOrderDetailQuantity(
      OrderDetail orderDetail, int newQuantity, String newNote) async {
    if (_selectedTable != null) {
      try {
        // Update quantity of a product in the order_details collection
        await _firestore
            .collection('orders')
            .doc(_selectedTable!.id)
            .collection('order_details')
            .doc(orderDetail.productId)
            .update({'quantity': newQuantity, 'note': newNote});

        // Update local state if needed
        setState(() {
          for (var detail in _orderDetails) {
            if (detail.productId == orderDetail.productId) {
              detail.quantity = newQuantity;
              break; // Exit loop once found and updated
            }
          }
        });

        // Update table status after updating quantity
        // await _updateTableStatus(_selectedTable!.id);
      } catch (e) {
        print('Error updating order detail quantity: $e');
      }
    }
  }

  void _remove2OrderDetail(OrderDetail orderDetail) async {
    if (_selectedTable != null) {
      try {
        // Delete a product from the order_details collection
        await _firestore
            .collection('orders')
            .doc(_selectedTable!.id)
            .collection('order_details2')
            .doc(orderDetail.productId)
            .delete();

        // Update table status after deleting
        await _update2TableStatus(_selectedTable!.id);
      } catch (e) {
        print('Error removing order detail: $e');
      }
    }
  }

  void _removeOrderDetail(OrderDetail orderDetail) async {
    if (_selectedTable != null) {
      try {
        // Delete a product from the order_details collection
        await _firestore
            .collection('orders')
            .doc(_selectedTable!.id)
            .collection('order_details')
            .doc(orderDetail.productId)
            .delete();

        // Update table status after deleting

        await _updateTableStatus(_selectedTable!.id);
      } catch (e) {
        print('Error removing order detail: $e');
      }
    }
  }

  bool _canDragTable(String tableName, List<Tables> tables) {
    return tables.any((table) => table.name == tableName);
  }

  Future<void> _showDragTableDialog(List<Tables> tables) async {
    TextEditingController controller = TextEditingController();

    // Lọc các bàn theo trạng thái và hiển thị thành từng hàng
    List<Tables> addproduct =
        tables.where((table) => table.status == 'Gọi thêm').toList();
    List<Tables> activeTables =
        tables.where((table) => table.status == 'Đang hoạt động').toList();
    List<Tables> combinedActiveTables = activeTables + addproduct;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kéo bàn'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Ví dụ: 8,10,4'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Kéo'),
              onPressed: () {
                List<String> tableNames =
                    controller.text.split(',').map((e) => e.trim()).toList();
                bool isValid = true;

                // Kiểm tra các trường hợp lỗi
                for (var tableName in tableNames) {
                  if (!_isValidTableName(tableName) ||
                      !_canDragTable(tableName, combinedActiveTables)) {
                    isValid = false;
                    break;
                  }
                }

                if (!isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Tên bàn không hợp lệ hoặc không thể kéo bàn!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                setState(() {
                  // Tạo danh sách các bàn sẽ được thêm vào các nhóm kéo mới
                  List<String> tablesToMove = [];

                  // Kiểm tra từng bàn có nằm trong các nhóm kéo hiện tại không
                  for (var tableName in tableNames) {
                    bool foundGroup = false;

                    // Kiểm tra các nhóm bàn đã có
                    for (var group in _draggedTableGroups) {
                      // Nếu bàn nằm trong một nhóm đã có
                      if (group.contains(tableName)) {
                        foundGroup = true;
                        break;
                      }
                    }

                    // Nếu bàn không nằm trong bất kỳ nhóm nào đã có
                    if (!foundGroup) {
                      tablesToMove.add(tableName);
                    }
                  }

                  // Thêm nhóm bàn mới nếu có bàn được chọn để kéo
                  if (tablesToMove.isNotEmpty) {
                    _draggedTableGroups.add(tablesToMove);
                    _saveDraggedTableGroups(); // Lưu khi thêm nhóm bàn
                  }

                  // Kiểm tra lại các nhóm kéo, loại bỏ các nhóm chỉ chứa một bàn
                  _draggedTableGroups.removeWhere((group) => group.length == 1);
                });

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Tách'),
              onPressed: () {
                List<String> tableNames =
                    controller.text.split(',').map((e) => e.trim()).toList();
                bool isValid = true;

                // Kiểm tra các trường hợp lỗi
                for (var tableName in tableNames) {
                  if (!_isValidTableName(tableName) ||
                      !_canDragTable(tableName, combinedActiveTables)) {
                    isValid = false;
                    break;
                  }
                }

                if (!isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Tên bàn không hợp lệ hoặc không thể kéo bàn!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                setState(() {
                  // // Tạo danh sách các bàn sẽ được tách ra khỏi các nhóm kéo hiện tại
                  // List<String> tablesToSplit = [];

                  // // Kiểm tra từng bàn có nằm trong các nhóm kéo hiện tại không
                  // for (var tableName in tableNames) {
                  //   // Tìm và tách bàn từ các nhóm kéo hiện tại
                  //   for (var group in _draggedTableGroups) {
                  //     if (group.contains(tableName)) {
                  //       group.remove(tableName);
                  //       tablesToSplit.add(tableName);
                  //       break;
                  //     }
                  //   }
                  // }
                  // Tạo danh sách các bàn sẽ được tách ra khỏi các nhóm kéo hiện tại
                  List<String> tablesToSplit = [];

                  // Tạo một bản sao của _draggedTableGroups để xử lý
                  List<List<String>> updatedGroups =
                      List.from(_draggedTableGroups);

                  // Kiểm tra từng bàn có nằm trong các nhóm kéo hiện tại không
                  for (var tableName in tableNames) {
                    // Tìm và tách bàn từ các nhóm kéo hiện tại
                    for (var group in updatedGroups) {
                      if (group.contains(tableName)) {
                        group.remove(tableName);
                        break;
                      }
                    }
                  }
                  _draggedTableGroups = updatedGroups;

                  // Loại bỏ các nhóm không có bàn sau khi tách
                  _draggedTableGroups.removeWhere((group) => group.isEmpty);

                  _saveDraggedTableGroups();
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isValidTableName(String tableName) {
    // Kiểm tra tên bàn có phải là số không
    try {
      int.parse(tableName.replaceAll('Bàn', '').trim());
      // Kiểm tra status của bàn (chỉ cho kéo khi bàn đang hoạt động)
      // Thêm các yêu cầu kiểm tra khác nếu cần
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveDraggedTableGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = _draggedTableGroups.map((group) {
      return group.join(',');
    }).toList();
    await prefs.setStringList('dolio', jsonList);
  }

  // Hàm đọc danh sách nhóm bàn từ SharedPreferences
  Future<void> _loadDraggedTableGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = prefs.getStringList('dolio') ?? [];
    _draggedTableGroups = jsonList.map((json) {
      return json.split(',');
    }).toList();
  }

  Widget _buildTableList2(String title, List<Tables> tables) {
    List<Tables> otherTables = tables.where((table) {
      bool isDragged = false;
      for (var group in _draggedTableGroups) {
        if (group.contains(table.name)) {
          isDragged = true;
          break;
        }
      }
      return !isDragged;
    }).toList();

    return Container(
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: const Color.fromARGB(255, 213, 205, 132),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: roundedElevatedButton(
                      onPressed: () => _showDragTableDialog(
                          tables), // Truyền context và danh sách bàn vào hàm _showDragTableDialog
                      text: "Kéo bàn",
                      backgroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                // Hiển thị các nhóm bàn được kéo trong các khung màu vàng
                for (var group in _draggedTableGroups)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio:
                            1, // Aspect ratio 1:1 for square appearance
                      ),
                      itemCount: group.length,
                      itemBuilder: (context, index) {
                        String tableName = group[index];
                        Tables table =
                            tables.firstWhere((t) => t.name == tableName);

                        bool isSelected = table.id == _selectedTableId;

                        // Xác định màu nền dựa trên trạng thái của bàn
                        Color backgroundColor;
                        switch (table.status) {
                          case 'Chờ duyệt':
                            backgroundColor =
                                const Color.fromARGB(255, 225, 99, 91);
                            break;
                          case 'Đang hoạt động':
                            backgroundColor =
                                const Color.fromARGB(255, 96, 220, 100);
                            break;
                          case 'Gọi thêm':
                            backgroundColor =
                                _backgroundColor; // đổi màu đỏ vàng liên tục
                            break;
                          case 'Trống':
                          default:
                            backgroundColor =
                                const Color.fromARGB(255, 207, 205, 205);
                            break;
                        }

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTable = table; // Cập nhật bàn được chọn
                              _selectedTableId = table.id;
                              isActive = table.status == 'Đang hoạt động';
                              isPendingApproval = table.status == 'Chờ duyệt';
                              isCallMore = table.status == 'Gọi thêm';
                            });
                            _openOrderDialog(table);
                          },
                          child: Material(
                            borderRadius: BorderRadius.circular(8),
                            elevation: isSelected ? 6 : 3,
                            color: isSelected
                                ? backgroundColor.withOpacity(0.7)
                                : backgroundColor,
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
                                    isActive = table.status == 'Đang hoạt động';
                                    isPendingApproval =
                                        table.status == 'Chờ duyệt';
                                    isCallMore = table.status == 'Gọi thêm';
                                  });
                                  _openOrderDialog(table);
                                },
                                splashColor: Colors.grey.withOpacity(0.5),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Bàn ${table.name}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.white,
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
                  ),
                // Hiển thị các bàn còn lại
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio:
                        1, // Aspect ratio 1:1 for square appearance
                  ),
                  itemCount: otherTables.length,
                  itemBuilder: (context, index) {
                    Tables table = otherTables[index];
                    bool isSelected = table.id == _selectedTableId;

                    // Xác định màu nền dựa trên trạng thái của bàn
                    Color backgroundColor;
                    switch (table.status) {
                      case 'Chờ duyệt':
                        backgroundColor =
                            const Color.fromARGB(255, 225, 99, 91);
                        break;
                      case 'Đang hoạt động':
                        backgroundColor =
                            const Color.fromARGB(255, 96, 220, 100);
                        break;
                      case 'Gọi thêm':
                        backgroundColor =
                            _backgroundColor; // đổi màu đỏ vàng liên tục
                        break;
                      case 'Trống':
                      default:
                        backgroundColor =
                            const Color.fromARGB(255, 207, 205, 205);
                        break;
                    }

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTable = table; // Cập nhật bàn được chọn
                          _selectedTableId = table.id;
                          isActive = table.status == 'Đang hoạt động';
                          isPendingApproval = table.status == 'Chờ duyệt';
                          isCallMore = table.status == 'Gọi thêm';
                        });
                        _openOrderDialog(table);
                      },
                      child: Material(
                        borderRadius: BorderRadius.circular(8),
                        elevation: isSelected ? 6 : 3,
                        color: isSelected
                            ? backgroundColor.withOpacity(0.7)
                            : backgroundColor,
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
                                isActive = table.status == 'Đang hoạt động';
                                isPendingApproval = table.status == 'Chờ duyệt';
                                isCallMore = table.status == 'Gọi thêm';
                              });
                              _openOrderDialog(table);
                            },
                            splashColor: Colors.grey.withOpacity(0.5),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Bàn ${table.name}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
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
          ),
        ],
      ),
    );
  }

  Widget _buildTableList(String title, List<Tables> tables) {
    return Container(
      color: Colors.grey.shade100,
      //  padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: const Color.fromARGB(255, 213, 205, 132),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1, // Aspect ratio 1:1 for square appearance
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                Tables table = tables[index];
                bool isSelected = table.id == _selectedTableId;

                // Xác định màu nền dựa trên trạng thái của bàn
                Color backgroundColor;
                switch (table.status) {
                  case 'Chờ duyệt':
                    backgroundColor = const Color.fromARGB(255, 225, 99, 91);
                    break;
                  case 'Đang hoạt động':
                    backgroundColor = const Color.fromARGB(255, 96, 220, 100);
                    break;
                  case 'Gọi thêm':
                    backgroundColor =
                        _backgroundColor; // đổi màu đỏ vàng liên tục
                    break;
                  case 'Trống':
                  default:
                    backgroundColor = const Color.fromARGB(255, 207, 205, 205);
                    break;
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTable = table; // Cập nhật bàn được chọn
                      _selectedTableId = table.id;
                      isActive = table.status == 'Đang hoạt động';
                      isPendingApproval = table.status == 'Chờ duyệt';
                      isCallMore = table.status == 'Gọi thêm';
                    });
                    _openOrderDialog(table);
                  },
                  child: Material(
                    borderRadius: BorderRadius.circular(8),
                    elevation: isSelected ? 6 : 3,
                    color: isSelected
                        ? backgroundColor.withOpacity(0.7)
                        : backgroundColor,
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
                            isActive = table.status == 'Đang hoạt động';
                            isPendingApproval = table.status == 'Chờ duyệt';
                            isCallMore = table.status == 'Gọi thêm';
                          });
                          _openOrderDialog(table);
                        },
                        splashColor: Colors.grey.withOpacity(0.5),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Bàn ${table.name}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color:
                                      isSelected ? Colors.black : Colors.white,
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
          ),
        ],
      ),
    );
  }

//Sửa sản phẩm more
  void _showProduct2DetailDialog(OrderDetail orderDetail) {
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
                    _remove2OrderDetail(orderDetail);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Lưu'),
                  onPressed: () {
                    _update2OrderDetailQuantity(
                        orderDetail, quantity, noteController.text);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Thoát'),
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

//Sửa sản phẩm
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
                  Text('Giá: ${FormartPrice(price: orderDetail.price)} '),
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
                  child: const Text('Thoát'),
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
                subtitle: Text('${FormartPrice(price: product.price)} '),
                onTap: () => _showAddQuantityDialog(product),
              );
            },
          ),
        );
      },
    );
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

//Thêm sản phẩm từ danh sách sản phẩm
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
                  Text('Giá: ${FormartPrice(price: product.price)} '),
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
                    (isActive == true || isCallMore == true)
                        ? _add2ToOrder(product, quantity, note)
                        : _addToOrder(product, quantity, note);
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
    if (_selectedTable != null) {
      try {
        // Add product to the order_details collection
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
          'note': note ?? '', // Ensure description is added
        });

        setState(() {
          isPendingApproval = true;
          selectAddProduct = _selectedTable!.id;
          isActive = false;
          print('Bàn thêm món${_selectedTable!.id}');
          print('Sao chép bàn thêm món$selectAddProduct');
        });
        await _updateTableStatus(_selectedTable!.id);
      } catch (e) {
        print('Error adding to order_details: $e');
      }
    }
  }

  Future<void> _update2TableStatus(String tableId) async {
    try {
      // Query order_details collection to determine item count
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .doc(tableId)
          .collection('order_details2')
          .get();

      // Calculate item count
      int itemCount = querySnapshot.docs.length;

      // Update table status based on item count
      String tableStatus = itemCount > 0 ? 'Gọi thêm' : 'Đang hoạt động';
      await _firestore.collection('tables').doc(tableId).update({
        'status': tableStatus,
      });
      setState(() {
        _selectedTable!.status = tableStatus;
      });
      setState(() {
        isCallMore = itemCount > 0;

        isActive = itemCount < 1;
      });
    } catch (e) {
      print('Error updating table status: $e');
    }
  }

  Future<void> _updateTableStatus(String tableId) async {
    try {
      // Query order_details collection to determine item count
      QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .doc(tableId)
          .collection('order_details')
          .get();

      // Calculate item count
      int itemCount = querySnapshot.docs.length;

      if (isActive == false) {
        String tableStatus = itemCount > 0 ? 'Chờ duyệt' : 'Trống';
        await _firestore.collection('tables').doc(tableId).update({
          'status': tableStatus,
        });
        setState(() {
          _selectedTable!.status = tableStatus;
        });
      }
    } catch (e) {
      print('Error updating table status: $e');
    }
  }

  void _openOrderDialog(Tables table) async {
    _selectedTable = table;
    _orderDetails = await _loadOrderDetails(table.id);
    setState(() {});
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

  Future<Uint8List> loadAsset(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  String FormartPrice({required double price}) {
    String formattedAmount =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
    return formattedAmount;
  }
}
