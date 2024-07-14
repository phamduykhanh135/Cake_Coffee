// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ThongKe2 extends StatefulWidget {
//   const ThongKe2({super.key});

//   @override
//   _ThongKeState createState() => _ThongKeState();
// }

// class _ThongKeState extends State<ThongKe2> {
//   DateTime? _startDate = DateTime.now();
//   DateTime? _endDate = DateTime.now();
//   double _totalRevenue = 0;
//   late Map<int, double> revenueByMonth = {};
//   final TextEditingController _employeeNameController = TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//     _fetchRevenueData();
//   }

//   @override
//   void dispose() {
//     _employeeNameController.dispose();
//     super.dispose();
//   }

//   void _searchInvoices() {
//     setState(() {});
//   }

//   void _fetchRevenueData() async {
//     try {
//       // Query invoices collection
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('ingredients')
//           .orderBy('create_time', descending: true)
//           .get();

//       // Initialize revenue map
//       revenueByMonth = {};

//       // Process query results
//       for (var doc in querySnapshot.docs) {
//         Timestamp createTime = doc['create_time'];
//         DateTime createDateTime = createTime.toDate();

//         // Check if invoice date is within selected date range
//         if ((_startDate == null ||
//                 createDateTime
//                     .isAfter(_startDate!.subtract(const Duration(days: 1)))) &&
//             (_endDate == null ||
//                 createDateTime
//                     .isBefore(_endDate!.add(const Duration(days: 1))))) {
//           int month = createDateTime.month;
//           double totalAmount = doc['total'];

//           // Accumulate revenue by month
//           if (revenueByMonth.containsKey(month)) {
//             revenueByMonth[month] = revenueByMonth[month]! + totalAmount;
//           } else {
//             revenueByMonth[month] = totalAmount;
//           }
//         }
//       }

//       // Sort revenueByMonth by keys (months) in ascending order
//       revenueByMonth = Map.fromEntries(revenueByMonth.entries.toList()
//         ..sort((a, b) => a.key.compareTo(b.key)));

//       // Update total revenue
//       setState(() {
//         _totalRevenue =
//             revenueByMonth.values.fold(0, (sum, amount) => sum + amount);
//       });
//     } catch (e) {
//       print('Error fetching revenue data: $e');
//     }
//   }

//   Future<void> _selectStartDate(BuildContext context) async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _startDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: _endDate ?? DateTime.now(),
//     );
//     if (pickedDate != null) {
//       setState(() {
//         _startDate = pickedDate;
//         _fetchRevenueData(); // Update revenue data when start date changes
//       });
//     }
//   }

//   Future<void> _selectEndDate(BuildContext context) async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _endDate ?? DateTime.now(),
//       firstDate: _startDate ?? DateTime.now(),
//       lastDate: DateTime.now(),
//     );
//     if (pickedDate != null) {
//       setState(() {
//         _endDate = pickedDate;
//         _fetchRevenueData(); // Update revenue data when end date changes
//       });
//     }
//   }

//   Color _getRandomColor() {
//     final Random random = Random();
//     return Color.fromRGBO(
//       random.nextInt(256),
//       random.nextInt(256),
//       random.nextInt(256),
//       1,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Danh sách vốn'),
//               Tab(text: 'Biểu đồ vốn'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildInvoiceListTab(context),
//             _buildRevenueChartTab(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInvoiceListTab(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 4,
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width * 0.12,
//                         height: 50,
//                         child: const Text(
//                           'Chọn khoảng thời gian:',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         width: MediaQuery.of(context).size.width * 0.1,
//                         height: 70,
//                         child: GestureDetector(
//                           onTap: () => _selectStartDate(context),
//                           child: AbsorbPointer(
//                             child: TextFormField(
//                               decoration: InputDecoration(
//                                 labelText: 'Ngày bắt đầu',
//                                 hintText: _startDate != null
//                                     ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
//                                     : 'Chọn ngày',
//                                 border: const OutlineInputBorder(),
//                               ),
//                               controller: TextEditingController(
//                                 text: _startDate != null
//                                     ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
//                                     : '',
//                               ),
//                               enabled: true,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         child: const Text('->'),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         width: MediaQuery.of(context).size.width * 0.1,
//                         height: 70,
//                         child: GestureDetector(
//                           onTap: () => _selectEndDate(context),
//                           child: AbsorbPointer(
//                             child: TextFormField(
//                               decoration: InputDecoration(
//                                 labelText: 'Ngày kết thúc',
//                                 hintText: _endDate != null
//                                     ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
//                                     : 'Chọn ngày',
//                                 border: const OutlineInputBorder(),
//                               ),
//                               controller: TextEditingController(
//                                 text: _endDate != null
//                                     ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
//                                     : '',
//                               ),
//                               enabled: true,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(flex: 1, child: Container()),
//               ],
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Row(
//             children: [
//               SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.12,
//                   height: 50,
//                   child: const Text(
//                     'Lọc theo:',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                   )),
//               Expanded(
//                 flex: 2,
//                 child: Row(
//                   children: [
//                     const SizedBox(width: 16.0),
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.2,
//                       child: TextFormField(
//                         controller: _employeeNameController,
//                         onChanged: (value) => _searchInvoices(),
//                         decoration: const InputDecoration(
//                           labelText: 'Tên nguyên liệu',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             Text(
//               'Tổng vốn ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_totalRevenue)}',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         Expanded(
//           child: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('ingredients')
//                 .orderBy('create_time', descending: true)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               }
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               // Process snapshot data
//               List<DocumentSnapshot> invoices = snapshot.data!.docs;
//               if (_startDate != null && _endDate != null) {
//                 invoices = invoices.where((invoice) {
//                   Timestamp createTime = invoice['create_time'];
//                   DateTime createDateTime = createTime.toDate();
//                   return createDateTime.isAfter(
//                           _startDate!.subtract(const Duration(days: 1))) &&
//                       createDateTime
//                           .isBefore(_endDate!.add(const Duration(days: 1)));
//                 }).toList();
//               }

//               if (_employeeNameController.text.isNotEmpty) {
//                 invoices = invoices.where((invoice) {
//                   return invoice['name']
//                       .toLowerCase()
//                       .contains(_employeeNameController.text.toLowerCase());
//                 }).toList();
//               }

//               if (invoices.isEmpty) {
//                 return const Center(
//                   child: Text('Không có nguyên liệu nào được tìm thấy!'),
//                 );
//               }

//               return Container(
//                             padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
//                             child: Card(
//                               child: ExpansionTile(
//                                 title: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                         'Mã hóa đơn: ${invoice['invoice_id']}'),
//                                     Text(
//                                         'Ngày xuất: ${_formatDate(invoiceDate)}'),
//                                     Text('Nhân viên: ${invoice['employee']}'),
//                                     Text(
//                                         'Tổng tiền: ${invoice['total_amount']}.đ'),
//                                   ],
//                                 ),
//                                 children: [
//                                   const Divider(),
//                                   Padding(
//                                     padding: const EdgeInsets.all(16.0),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const Row(
//                                           children: [
//                                             Expanded(
//                                               child: Text(
//                                                 'Sản phẩm',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Text(
//                                                 'Đơn giá',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Text(
//                                                 'Số lượng',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: Text(
//                                                 'Thành tiền',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const Divider(),
//                                         ...orderDetails.asMap().entries.map(
//                                           (entry) {
//                                             int stt = entry.key + 1;
//                                             var detail = entry.value;
//                                             var productName =
//                                                 detail['product_name'];
//                                             var unitPrice = detail['price'];
//                                             var quantity = detail['quantity'];
//                                             var totalPrice =
//                                                 unitPrice * quantity;

//                                             return Row(
//                                               children: [
//                                                 Expanded(
//                                                   child: Text(
//                                                       '$stt. $productName'),
//                                                 ),
//                                                 Expanded(
//                                                   child: Text(
//                                                       '${unitPrice.toStringAsFixed(2)}đ'),
//                                                 ),
//                                                 Expanded(
//                                                   child: Text('$quantity'),
//                                                 ),
//                                                 Expanded(
//                                                   child: Text(
//                                                       '${totalPrice.toStringAsFixed(2)}đ'),
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                         ),
//                                         const Divider(),
//                                         if (invoice['phone_Customer'] != "")
//                                           Text(
//                                               'SĐT khách hàng thành viên: ${invoice['phone_Customer']}'),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             const Text(
//                                               'Tổng hóa đơn:',
//                                               style: TextStyle(),
//                                             ),
//                                             Text(
//                                               '${invoice['total_bill'].toStringAsFixed(2)}đ',
//                                               style: const TextStyle(),
//                                             ),
//                                           ],
//                                         ),
//                                         if (invoice['vourcher'] > 0)
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               const Text(
//                                                 'Vourcher giảm giá:',
//                                                 style: TextStyle(),
//                                               ),
//                                               Text(
//                                                 '${invoice['vourcher'].toStringAsFixed(2)}đ',
//                                                 style: const TextStyle(),
//                                               ),
//                                             ],
//                                           ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             const Text(
//                                               'Tổng cộng:',
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Text(
//                                               '${invoice['total_amount'].toStringAsFixed(2)}đ',
//                                               style: const TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//               // ListView.builder(
//               //   itemCount: invoices.length,
//               //   itemBuilder: (context, index) {
//               //     DocumentSnapshot invoice = invoices[index];
//               //     Timestamp createTime = invoice['create_time'];
//               //     DateTime createDateTime = createTime.toDate();
//               //     return ListTile(
//               //       title: Text('Hóa đơn: ${invoice['name']}'),
//               //       subtitle: Text(
//               //         'Ngày tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(createDateTime)}\nTổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(invoice['total'])}\n Tên nguyên liệu: ${invoice['name']}',
//               //       ),
//               //       onTap: () {
//               //         Navigator.push(
//               //           context,
//               //           MaterialPageRoute(
//               //             builder: (context) =>
//               //                 InvoiceDetailScreen(invoiceId: invoice.id),
//               //           ),
//               //         );
//               //       },
//               //     );
//               //   },
//               // );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRevenueChartTab(BuildContext context) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Row(
//                   children: [
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.12,
//                       height: 50,
//                       child: const Text(
//                         'Chọn khoảng thời gian:',
//                         style: TextStyle(
//                             fontSize: 15, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       width: MediaQuery.of(context).size.width * 0.1,
//                       height: 70,
//                       child: GestureDetector(
//                         onTap: () => _selectStartDate(context),
//                         child: AbsorbPointer(
//                           child: TextFormField(
//                             decoration: InputDecoration(
//                               labelText: 'Ngày bắt đầu',
//                               hintText: _startDate != null
//                                   ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
//                                   : 'Chọn ngày',
//                               border: const OutlineInputBorder(),
//                             ),
//                             controller: TextEditingController(
//                               text: _startDate != null
//                                   ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
//                                   : '',
//                             ),
//                             enabled: true,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       child: const Text('->'),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       width: MediaQuery.of(context).size.width * 0.1,
//                       height: 70,
//                       child: GestureDetector(
//                         onTap: () => _selectEndDate(context),
//                         child: AbsorbPointer(
//                           child: TextFormField(
//                             decoration: InputDecoration(
//                               labelText: 'Ngày kết thúc',
//                               hintText: _endDate != null
//                                   ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
//                                   : 'Chọn ngày',
//                               border: const OutlineInputBorder(),
//                             ),
//                             controller: TextEditingController(
//                               text: _endDate != null
//                                   ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
//                                   : '',
//                             ),
//                             enabled: true,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Text(
//                       'Tổng doanh thu: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_totalRevenue)}',
//                       style: const TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SfCartesianChart(
//               primaryXAxis: const CategoryAxis(),
//               primaryYAxis: NumericAxis(
//                 numberFormat: NumberFormat.compactCurrency(
//                     locale: 'vi_VN', symbol: '₫', decimalDigits: 0),
//               ),
//               tooltipBehavior: TooltipBehavior(enable: true),
//               series: <CartesianSeries>[
//                 ColumnSeries<MapEntry<int, double>, String>(
//                   dataSource: revenueByMonth.entries.toList(),
//                   xValueMapper: (MapEntry<int, double> entry, _) =>
//                       'Tháng ${entry.key}',
//                   yValueMapper: (MapEntry<int, double> entry, _) => entry.value,
//                   dataLabelSettings: const DataLabelSettings(isVisible: true),
//                   color: _getRandomColor(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class InvoiceDetailScreen extends StatelessWidget {
//   final String invoiceId;

//   const InvoiceDetailScreen({super.key, required this.invoiceId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Chi tiết hóa đơn'),
//       ),
//       body: Center(
//         child: Text('Thông tin chi tiết của hóa đơn $invoiceId'),
//       ),
//     );
//   }
// }
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThongKe2 extends StatefulWidget {
  const ThongKe2({super.key});

  @override
  _ThongKeState createState() => _ThongKeState();
}

class _ThongKeState extends State<ThongKe2> {
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now();
  double _totalRevenue = 0;
  late Map<int, double> revenueByMonth = {};
  final TextEditingController _employeeNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRevenueData();
  }

  @override
  void dispose() {
    _employeeNameController.dispose();
    super.dispose();
  }

  void _searchInvoices() {
    setState(() {});
  }

  void _fetchRevenueData() async {
    try {
      // Query invoices collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ingredients')
          .orderBy('create_time', descending: true)
          .get();

      // Initialize revenue map
      revenueByMonth = {};

      // Process query results
      for (var doc in querySnapshot.docs) {
        Timestamp createTime = doc['create_time'];
        DateTime createDateTime = createTime.toDate();

        // Check if invoice date is within selected date range
        if ((_startDate == null ||
                createDateTime
                    .isAfter(_startDate!.subtract(const Duration(days: 1)))) &&
            (_endDate == null ||
                createDateTime
                    .isBefore(_endDate!.add(const Duration(days: 1))))) {
          int month = createDateTime.month;
          double totalAmount = doc['total'];

          // Accumulate revenue by month
          if (revenueByMonth.containsKey(month)) {
            revenueByMonth[month] = revenueByMonth[month]! + totalAmount;
          } else {
            revenueByMonth[month] = totalAmount;
          }
        }
      }

      // Sort revenueByMonth by keys (months) in ascending order
      revenueByMonth = Map.fromEntries(revenueByMonth.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)));

      // Update total revenue
      setState(() {
        _totalRevenue =
            revenueByMonth.values.fold(0, (sum, amount) => sum + amount);
      });
    } catch (e) {
      print('Error fetching revenue data: $e');
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: _endDate ?? DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
        _fetchRevenueData(); // Update revenue data when start date changes
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
        _fetchRevenueData(); // Update revenue data when end date changes
      });
    }
  }

  Color _getRandomColor() {
    final Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Danh sách vốn'),
              Tab(text: 'Biểu đồ vốn'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInvoiceListTab(context),
            _buildRevenueChartTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceListTab(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
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
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
              Expanded(flex: 1, child: Container()),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.12,
                height: 50,
                child: const Text(
                  'Lọc theo:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    const SizedBox(width: 16.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: TextFormField(
                        controller: _employeeNameController,
                        onChanged: (value) => _searchInvoices(),
                        decoration: const InputDecoration(
                          labelText: 'Tên nguyên liệu',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Tổng vốn ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_totalRevenue)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('ingredients')
                .orderBy('create_time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Process snapshot data
              List<DocumentSnapshot> invoices = snapshot.data!.docs;
              if (_startDate != null && _endDate != null) {
                invoices = invoices.where((invoice) {
                  Timestamp createTime = invoice['create_time'];
                  DateTime createDateTime = createTime.toDate();
                  return createDateTime.isAfter(
                          _startDate!.subtract(const Duration(days: 1))) &&
                      createDateTime
                          .isBefore(_endDate!.add(const Duration(days: 1)));
                }).toList();
              }

              if (_employeeNameController.text.isNotEmpty) {
                String searchText = _employeeNameController.text.toLowerCase();
                invoices = invoices.where((invoice) {
                  String employeeName = invoice['name'].toLowerCase();
                  return employeeName.contains(searchText);
                }).toList();
              }

              if (invoices.isEmpty) {
                return const Center(child: Text('Không có dữ liệu'));
              }

              return ListView.builder(
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  var invoice = invoices[index].data() as Map<String, dynamic>;
                  var createDateTime =
                      (invoice['create_time'] as Timestamp).toDate();
                  var formattedDate =
                      DateFormat('dd/MM/yyyy').format(createDateTime);
                  return ListTile(
                    title: Text(invoice['name']),
                    subtitle: Text(
                        'Ngày: $formattedDate\nTổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(invoice['total'])}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChartTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.12,
                      height: 50,
                      child: const Text(
                        'Chọn khoảng thời gian:',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
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
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Tổng doanh thu: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_totalRevenue)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.compactCurrency(
                    locale: 'vi_VN', symbol: '₫', decimalDigits: 0),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                ColumnSeries<MapEntry<int, double>, String>(
                  dataSource: revenueByMonth.entries.toList(),
                  xValueMapper: (MapEntry<int, double> entry, _) =>
                      'Tháng ${entry.key}',
                  yValueMapper: (MapEntry<int, double> entry, _) => entry.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  color: _getRandomColor(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
