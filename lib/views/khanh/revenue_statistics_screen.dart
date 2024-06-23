import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Revenue_Statistics_Creen extends StatefulWidget {
  const Revenue_Statistics_Creen({super.key});

  @override
  State<Revenue_Statistics_Creen> createState() =>
      _Revenue_Statistics_CreenState();
}

class _Revenue_Statistics_CreenState extends State<Revenue_Statistics_Creen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> categories = [
    {'id': '001', 'name': 'Đồ uống', 'description': 'Không có'},
    {'id': '002', 'name': 'Đồ ăn', 'description': 'Không có'},
  ];

  final List<Map<String, String>> products = [
    {
      'id': 'P001',
      'categoryId': '001',
      'name': 'Cà phê sữa đá',
      'unit': 'Ly',
      'price': '12.000đ',
      'description': 'Không có',
      'image': 'Trống'
    },
    {
      'id': 'P002',
      'categoryId': '002',
      'name': 'Bánh Coistant',
      'unit': 'Cái',
      'price': '12.000đ',
      'description': 'Không có',
      'image': 'Trống'
    },
    {
      'id': 'P003',
      'categoryId': '001',
      'name': 'Cà phê muối',
      'unit': 'Ly',
      'price': '12.000đ',
      'description': 'Không có',
      'image': 'Trống'
    },
  ];
  String _getCategoryNameById(String categoryId) {
    final category = categories.firstWhere(
      (category) => category['id'] == categoryId,
      orElse: () => {'name': 'Unknown'},
    );
    return category['name'] ?? 'Unknown';
  }

  late TabController _tabController;
  void _showOptionsDialog(Map<String, String> data) {
    // final bool isCategory = data.containsKey('categoryId');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tùy chọn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    //  Text('ID: ${data['id']}'),
                    Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width *
                          0.2, // Đặt độ rộng của Container chứa TextFormField
                      height: 30, // Đặt chiều cao của TextFormField
                      child: TextFormField(
                        initialValue:
                            data['id'], // Giá trị ban đầu của TextFormField
                        onChanged: (newValue) {
                          // Xử lý khi giá trị của TextFormField thay đổi
                          setState(() {
                            data['id'] =
                                newValue; // Cập nhật giá trị mới vào Map
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          //labelText: 'ID',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    //  Text('ID: ${data['id']}'),
                    Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width *
                          0.2, // Đặt độ rộng của Container chứa TextFormField
                      height: 30, // Đặt chiều cao của TextFormField
                      child: TextFormField(
                        initialValue:
                            data['name'], // Giá trị ban đầu của TextFormField
                        onChanged: (newValue) {
                          // Xử lý khi giá trị của TextFormField thay đổi
                          setState(() {
                            data['name'] =
                                newValue; // Cập nhật giá trị mới vào Map
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          //labelText: 'Name',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    //  Text('ID: ${data['id']}'),
                    Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width *
                          0.2, // Đặt độ rộng của Container chứa TextFormField
                      height: 30, // Đặt chiều cao của TextFormField
                      child: TextFormField(
                        initialValue: data[
                            'description'], // Giá trị ban đầu của TextFormField
                        onChanged: (newValue) {
                          // Xử lý khi giá trị của TextFormField thay đổi
                          setState(() {
                            data['description'] =
                                newValue; // Cập nhật giá trị mới vào Map
                          });
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          //  labelText: 'Mô tả',
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Text('ID: ${data['id']}'),
              // Text('Tên: ${data['name']}'),
              // Text('Mô tả: ${data['description']}'),
              // if (isCategory) ...[
              //   Text('Danh mục: ${_getCategoryNameById(data['categoryId']!)}'),
              // ],
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng dialog
                  _editItem(data); // Xử lý khi nhấn nút Sửa
                },
                child: const Text('Sửa'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng dialog
                  _deleteItem(data); // Xử lý khi nhấn nút Xóa
                },
                child: const Text('Xóa'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editItem(Map<String, String> data) {
    // Xử lý khi nhấn nút Sửa
    print('Sửa: ${data.toString()}');
  }

  void _deleteItem(Map<String, String> data) {
    // Xử lý khi nhấn nút Xóa
    print('Xóa: ${data.toString()}');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this); // Two tabs: Products and Categories
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // width: MediaQuery.of(context).size.width *
            //     0.3, // Width of the left sidebar for TabBar
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //const SizedBox(height: 20),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Báo cáo danh thu'), // First tab: Products
                    Tab(text: 'Lợi nhuận'), // Second tab: Categories
                  ],
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black,
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _product(), // Content for Products tab
                _category()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _product() {
    return Container(
        padding: const EdgeInsets.all(10),
        // Placeholder for Categories tab content, replace with your actual implementation
        child: Column(
          children: [
            const Row(
              children: [
                Text(
                  'Thông tin sản phẩm',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width *
                            0.2, // Đặt độ rộng của Container chứa TextFormField
                        height: 30, // Đặt chiều cao của TextFormField
                        child: TextFormField(
                          style: const TextStyle(
                              fontSize:
                                  15), // Đặt kích thước chữ cho TextFormField
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal:
                                    10), // Đặt padding cho phần nội dung bên trong TextFormField
                            border:
                                OutlineInputBorder(), // Đặt đường viền xung quanh TextFormField
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Container(
                  child: roundedElevatedButton(
                      onPressed: () {},
                      text: "Thêm",
                      backgroundColor: Colors.green),
                )
              ],
            ),

            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: _buildProductTable()),
          ],
        ));
  }

  Widget _category() {
    return Container(
        padding: const EdgeInsets.all(10),
        // Placeholder for Categories tab content, replace with your actual implementation
        child: Column(
          children: [
            const Row(
              children: [
                Text(
                  'Thông tin danh mục',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width *
                            0.2, // Đặt độ rộng của Container chứa TextFormField
                        height: 30, // Đặt chiều cao của TextFormField
                        child: TextFormField(
                          style: const TextStyle(
                              fontSize:
                                  15), // Đặt kích thước chữ cho TextFormField
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal:
                                    10), // Đặt padding cho phần nội dung bên trong TextFormField
                            border:
                                OutlineInputBorder(), // Đặt đường viền xung quanh TextFormField
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Container(
                  child: roundedElevatedButton(
                      onPressed: () {},
                      text: "Thêm",
                      backgroundColor: Colors.green),
                )
              ],
            ),

            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: _buildCategoryTable()),
          ],
        ));
  }

  Widget _buildCategoryTable() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 3,
      child: DataTable(
        // columnSpacing: 343, // Điều chỉnh khoảng cách giữa các cột
        // horizontalMargin: 200, // Điều chỉnh margin ngang của DataTable
        columns: const [
          DataColumn(
            label: Text('Mã danh mục',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
          ),
          DataColumn(
            label: Text('Tên danh mục',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Mô tả', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label:
                Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: categories.map((category) {
          return DataRow(
            cells: [
              DataCell(Text(category['id'] ?? '')),
              DataCell(Text(category['name'] ?? '')),
              DataCell(Text(category['description'] ?? '')),
              DataCell(Container(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: roundedElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(
                                category); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
                          },
                          text: "Sửa",
                          backgroundColor: Colors.yellow),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: roundedElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(
                                category); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
                          },
                          text: "Xóa",
                          backgroundColor: Colors.red),
                    ),
                  ],
                ),
              )),
            ],
            // onSelectChanged: (isSelected) {
            //   _showOptionsDialog(
            //       category); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
            // },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductTable() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 3,
      child: DataTable(
        //columnSpacing: 185,
        columns: const [
          DataColumn(
            label: Text(
              'Tên món',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Đơn vị tính',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Đơn giá',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Mô tả',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Danh mục',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label:
                Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: List<DataRow>.generate(products.length, (index) {
          var product = products[index];
          return DataRow(
            cells: [
              DataCell(Text(product['name'] ?? '')),
              DataCell(Text(product['unit'] ?? '')),
              DataCell(Text(product['price'] ?? '')),
              DataCell(Text(product['description'] ?? '')),
              DataCell(
                Text(
                  _getCategoryNameById(product['categoryId'] ?? ''),
                ),
              ),
              DataCell(Container(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: roundedElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(
                                product); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
                          },
                          text: "Sửa",
                          backgroundColor: Colors.yellow),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: roundedElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(
                                product); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
                          },
                          text: "Xóa",
                          backgroundColor: Colors.red),
                    ),
                  ],
                ),
              )),
            ],
          );
        }),
      ),
    );
  }
}
