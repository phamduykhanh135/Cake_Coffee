import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:intl/intl.dart';

class Statistical_Material_Screen extends StatefulWidget {
  const Statistical_Material_Screen({super.key});

  @override
  _Statistical_Material_ScreenState createState() =>
      _Statistical_Material_ScreenState();
}

class _Statistical_Material_ScreenState
    extends State<Statistical_Material_Screen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now();

  double totalSum = 0;

  @override
  void dispose() {
    _searchController.dispose(); // Giải phóng bộ nhớ khi widget bị huỷ
    super.dispose();
  }

  void _searchInvoices() {
    setState(() {});
  }

  // Hàm chọn ngày bắt đầu lọc
  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _endDate ?? DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate; // Cập nhật ngày bắt đầu
      });
    }
  }

  // Hàm chọn ngày kết thúc lọc
  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      // Xử lý trường hợp chưa chọn ngày bắt đầu
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Chưa chọn ngày bắt đầu'),
            content:
                const Text('Chọn ngày bắt đầu trước khi chọn ngày kết thúc!.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Đóng'),
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng dialog
                },
              ),
            ],
          );
        },
      );
      return;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate!,
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate; // Cập nhật ngày kết thúc
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Phần lọc theo ngày/tháng
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Lọc theo ngày

                  // Lọc theo tháng
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.12,
                            height: 50,
                            child: const Text(
                              'Chọn khoảng thời gian:',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            )),
                        Container(
                          padding: const EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: 70,
                          child: GestureDetector(
                            onTap: () => _selectStartDate(context),
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Ngày bắt đầu',
                                  hintText: _startDate != null
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                      : 'Chọn ngày',
                                  border: const OutlineInputBorder(),
                                ),
                                controller: TextEditingController(
                                  text: _startDate != null
                                      ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                      : '',
                                ),
                                enabled: true,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: const Text('->'),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width * 0.1,
                          height: 70,
                          child: GestureDetector(
                            onTap: () => _selectEndDate(context),
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Ngày kết thúc',
                                  hintText: _endDate != null
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : 'Chọn ngày',
                                  border: const OutlineInputBorder(),
                                ),
                                controller: TextEditingController(
                                  text: _endDate != null
                                      ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                      : '',
                                ),
                                enabled: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(flex: 1, child: Container())
                ],
              ),
            ),
          ),
          // Phần tìm kiếm theo tên nguyên liệu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: 50,
                    child: const Text(
                      'Lọc theo:',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Expanded(
                            child: TextFormField(
                              controller: _searchController,
                              onChanged: (value) => _searchInvoices(),
                              decoration: const InputDecoration(
                                labelText: 'Tên nguyên liệu',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                Expanded(flex: 1, child: Container())
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ingredients')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error: ${snapshot.error}')); // Hiển thị lỗi nếu có lỗi xảy ra
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }

                // Xử lý dử liệu snapshot
                List<DocumentSnapshot> ingredients = snapshot.data!.docs;

                // Lọc thành phần dựa trên truy vấn tìm kiếm
                if (_searchController.text.isNotEmpty) {
                  ingredients = ingredients.where((ingredient) {
                    String name = ingredient['name'].toString().toLowerCase();
                    String query = _searchController.text.toLowerCase();
                    return name.contains(query); // Lọc nguyên liệu theo tên
                  }).toList();
                }

                if (_startDate != null && _endDate != null) {
                  ingredients = ingredients.where((ingredient) {
                    Timestamp createTime = ingredient['create_time'];
                    DateTime createDateTime = createTime.toDate();
                    // Include the same day for both start and end dates
                    DateTime startDateTime = DateTime(
                        _startDate!.year, _startDate!.month, _startDate!.day);
                    DateTime endDateTime = DateTime(_endDate!.year,
                        _endDate!.month, _endDate!.day, 23, 59, 59);
                    return createDateTime.isAfter(startDateTime
                            .subtract(const Duration(seconds: 1))) &&
                        createDateTime.isBefore(
                            endDateTime.add(const Duration(seconds: 1)));
                  }).toList();
                }

                // Tính tổng vốn
                totalSum = ingredients.fold(0, (sum, ingredient) {
                  double price = double.parse(ingredient['price'].toString());
                  double quantity =
                      double.parse(ingredient['quantity'].toString());
                  return sum + (price * quantity); // Tính tổng vốn nhập vào
                });
                // Sắp xếp danh sách nguyên liệu theo ngày tăng dần
                ingredients.sort((a, b) {
                  Timestamp timeA = a['create_time'];
                  Timestamp timeB = b['create_time'];
                  DateTime dateTimeA = timeA.toDate();
                  DateTime dateTimeB = timeB.toDate();
                  return dateTimeA.compareTo(dateTimeB);
                });
                if (ingredients.isEmpty) {
                  return const Center(
                    child: Text('Không có nguyên liệu nào được tìm thấy!'),
                  );
                }

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Tổng vốn nhập vào: ${FormartPrice(price: totalSum)} ',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Header của danh sách nguyên liệu
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Card(
                        color: Colors.grey.shade300,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 0, 5, 5),
                          height: 50,
                          child: Container(
                            child: const Row(
                              children: [
                                Expanded(flex: 1, child: Text('STT')),
                                Expanded(
                                    flex: 3, child: Text('Tên nguyên liệu')),
                                Expanded(flex: 1, child: Text('Số lượng')),
                                Expanded(flex: 1, child: Text('Giá')),
                                Expanded(flex: 1, child: Text('Tổng giá')),
                                Expanded(flex: 1, child: Text('Ngày nhập')),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: ingredients.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ingredient = ingredients[index];
                          String ingredientName = ingredient['name'];
                          double price =
                              double.parse(ingredient['price'].toString());
                          double quantity =
                              double.parse(ingredient['quantity'].toString());

                          var createTime =
                              ingredient['create_time'] as Timestamp;
                          double total = price * quantity;
                          return Container(
                            child: Column(
                              children: [
                                Column(children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Card(
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 5, 5),
                                        height: 50,
                                        child: Container(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  flex: 1,
                                                  child: Text('${index + 1}')),
                                              Expanded(
                                                  flex: 3,
                                                  child: Text(ingredientName)),
                                              Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                      quantity.toString())),
                                              Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                      '${FormartPrice(price: price)} ')),
                                              Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                      '${FormartPrice(price: total)} ')),
                                              Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                      _formatDate(createTime))),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ])
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String FormartPrice({required double price}) {
    String formattedAmount =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
    return formattedAmount;
  }

  String _formatDate(Timestamp timestamp) {
    var date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
