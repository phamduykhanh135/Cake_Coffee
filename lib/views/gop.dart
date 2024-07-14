import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThongKe extends StatefulWidget {
  const ThongKe({super.key});

  @override
  _ThongKeState createState() => _ThongKeState();
}

class _ThongKeState extends State<ThongKe> {
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now();
  double _totalRevenue = 0;
  late Map<int, double> revenueByMonth = {};
  final TextEditingController _invoiceIdController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _fetchRevenueData();
  }

  @override
  void dispose() {
    _invoiceIdController.dispose();
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
          .collection('invoices')
          .orderBy('date', descending: true)
          .get();

      // Initialize revenue map
      revenueByMonth = {};

      // Process query results
      for (var doc in querySnapshot.docs) {
        Timestamp createTime = doc['date'];
        DateTime createDateTime = createTime.toDate();

        // Check if invoice date is within selected date range
        if ((_startDate == null ||
                createDateTime
                    .isAfter(_startDate!.subtract(const Duration(days: 1)))) &&
            (_endDate == null ||
                createDateTime
                    .isBefore(_endDate!.add(const Duration(days: 1))))) {
          int month = createDateTime.month;
          double totalAmount = doc['total_amount'];

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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              color: Colors.grey[200],
              child: const TabBar(
                tabs: [
                  Tab(text: 'Danh sách hóa đơn'),
                  Tab(text: 'Biểu đồ doanh thu'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildInvoiceListTab(context),
                  _buildRevenueChartTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceListTab(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: const Text(
                              'Chọn khoảng thời gian:',
                              style: TextStyle(),
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
                        const Divider(
                          color: Colors.black,
                          height: 1,
                          thickness: 1,
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                          width: MediaQuery.of(context).size.width * 0.08,
                          child: const Text('Tìm theo:'),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: TextFormField(
                            controller: _invoiceIdController,
                            onChanged: (value) => _searchInvoices(),
                            decoration: const InputDecoration(
                              labelText: 'Mã hóa đơn',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: TextFormField(
                            controller: _employeeNameController,
                            onChanged: (value) => _searchInvoices(),
                            decoration: const InputDecoration(
                              labelText: 'Tên nhân viên',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expanded(flex: 1, child: Container())
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('invoices').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }

                // Process snapshot data
                List<DocumentSnapshot> invoices = snapshot.data!.docs;
                if (_startDate != null && _endDate != null) {
                  invoices = invoices.where((invoice) {
                    Timestamp createTime = invoice['date'];
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

                if (_invoiceIdController.text.isNotEmpty) {
                  invoices = invoices.where((invoice) {
                    return invoice['invoice_id']
                        .toLowerCase()
                        .contains(_invoiceIdController.text.toLowerCase());
                  }).toList();
                }
                if (_employeeNameController.text.isNotEmpty) {
                  invoices = invoices.where((invoice) {
                    return invoice['employee']
                        .toLowerCase()
                        .contains(_employeeNameController.text.toLowerCase());
                  }).toList();
                }

                invoices.sort((a, b) {
                  return (a['invoice_id'] as String)
                      .compareTo(b['invoice_id'] as String);
                });

                _totalRevenue = invoices.fold(0, (sum, invoice) {
                  return sum + invoice['total_amount'];
                });
                if (invoices.isEmpty) {
                  return const Center(
                    child: Text('Không có hóa đơn nào được tìm thấy!'),
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
                            'Tổng danh thu: ${FormartPrice(price: _totalRevenue)}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: invoices.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot invoice = invoices[index];
                          var orderDetails = invoice['order_details'] ?? [];
                          var invoiceDate = invoice['date'] as Timestamp;

                          return Container(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                            child: Card(
                              child: ExpansionTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Mã hóa đơn: ${invoice['invoice_id']}'),
                                    Text(
                                        'Ngày xuất: ${_formatDate(invoiceDate)}'),
                                    Text('Nhân viên: ${invoice['employee']}'),
                                    Text(
                                        'Tổng tiền: ${FormartPrice(price: invoice['total_amount'])}'),
                                  ],
                                ),
                                children: [
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Sản phẩm',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                'Đơn giá',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                'Số lượng',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                'Thành tiền',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        ...orderDetails.asMap().entries.map(
                                          (entry) {
                                            int stt = entry.key + 1;
                                            var detail = entry.value;
                                            var productName =
                                                detail['product_name'];
                                            var unitPrice = detail['price'];
                                            var quantity = detail['quantity'];
                                            var totalPrice =
                                                unitPrice * quantity;

                                            return Column(
                                              children: [
                                                const Divider(),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                          '$stt. $productName'),
                                                    ),
                                                    Expanded(
                                                      child: Text(FormartPrice(
                                                          price: unitPrice)),
                                                    ),
                                                    Expanded(
                                                      child: Text('$quantity'),
                                                    ),
                                                    Expanded(
                                                      child: Text(FormartPrice(
                                                          price: totalPrice)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        const Divider(),
                                        if (invoice['phone_Customer'] != "")
                                          Text(
                                              'SĐT khách hàng thành viên: ${invoice['phone_Customer']}'),
                                        Row(
                                          children: [
                                            const Expanded(
                                              flex: 1,
                                              child: Text(
                                                'Tổng hóa đơn:',
                                                style: TextStyle(),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 2, child: Container()),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                FormartPrice(
                                                    price:
                                                        invoice['total_bill']),
                                                style: const TextStyle(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (invoice['vourcher'] > 0)
                                          Row(
                                            children: [
                                              const Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'Vourcher giảm giá:',
                                                  style: TextStyle(),
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 2, child: Container()),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  FormartPrice(
                                                      price:
                                                          invoice['vourcher']),
                                                  style: const TextStyle(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        Row(
                                          children: [
                                            const Expanded(
                                              flex: 1,
                                              child: Text(
                                                'Tổng cộng:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 2, child: Container()),
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                FormartPrice(
                                                    price: invoice[
                                                        'total_amount']),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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
              )),
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

  String FormartPrice({required double price}) {
    String formattedAmount =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
    return formattedAmount;
  }
}
