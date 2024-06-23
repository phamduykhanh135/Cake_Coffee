import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:flutter/material.dart'; // Import your Management_Product widget here

class Management_Table extends StatefulWidget {
  const Management_Table({super.key});

  @override
  _Management_Table createState() => _Management_Table();
}

class _Management_Table extends State<Management_Table>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> categories_table = [
    {'id': '001', 'name': 'Ngoài sân', 'description': 'Không có'},
    {'id': '002', 'name': 'Phòng lạnh', 'description': 'Không có'},
  ];

  final List<Map<String, String>> tables = [
    {
      'id': 'T001',
      'category_table_Id': '001',
      'name': 'Bàn 1',
      'description': 'Không có',
    },
    {
      'id': 'T002',
      'category_table_Id': '002',
      'name': 'Bàn 2',
      'description': 'Không có',
    },
    {
      'id': 'T003',
      'category_table_Id': '001',
      'name': 'Cà bàn 3',
      'description': 'Không có',
    },
  ];
  String _getCategoryNameById(String categoryId) {
    final categoryTable = categories_table.firstWhere(
      (categoryTable) => categoryTable['id'] == categoryId,
      orElse: () => {'name': 'Unknown'},
    );
    return categoryTable['name'] ?? 'Unknown';
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
                    Tab(text: 'Bàn'), // First tab: Products
                    Tab(text: 'Khu vực'), // Second tab: Categories
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
                _table(), // Content for Products tab
                _area()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _table() {
    return Container(
        padding: const EdgeInsets.all(10),
        // Placeholder for Categories tab content, replace with your actual implementation
        child: Column(
          children: [
            const Row(
              children: [
                Text(
                  'Thông tin bàn',
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
                width: MediaQuery.of(context).size.width, child: _buildTable()),
          ],
        ));
  }

  Widget _area() {
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
                width: MediaQuery.of(context).size.width, child: _buildArea()),
          ],
        ));
  }

  Widget _buildArea() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 3,
      child: DataTable(
        // columnSpacing: 343, // Điều chỉnh khoảng cách giữa các cột
        // horizontalMargin: 200, // Điều chỉnh margin ngang của DataTable
        columns: const [
          DataColumn(
            label: Text('Mã khu vực',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Tên khu vực',
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
        rows: categories_table.map((categoryTable) {
          return DataRow(
            cells: [
              DataCell(Text(categoryTable['id'] ?? '')),
              DataCell(Text(categoryTable['name'] ?? '')),
              DataCell(Text(categoryTable['description'] ?? '')),
              DataCell(Container(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: roundedElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(
                                categoryTable); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
                          },
                          text: "Sửa",
                          backgroundColor: Colors.yellow),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: roundedElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(
                                categoryTable); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
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

  Widget _buildTable() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 3,
      child: DataTable(
        //columnSpacing: 185,
        columns: const [
          DataColumn(
            label: Text(
              'Mã bàn',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Khu vực',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Tên bàn',
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
            label:
                Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: List<DataRow>.generate(tables.length, (index) {
          var table = tables[index];
          return DataRow(
            cells: [
              DataCell(Text(table['id'] ?? '')),
              DataCell(
                Text(
                  _getCategoryNameById(table['category_table_Id'] ?? ''),
                ),
              ),
              DataCell(Text(table['name'] ?? '')),
              DataCell(Text(table['description'] ?? '')),
              // DataCell(
              //   Text(
              //     _getCategoryNameById(product['category_table_Id'] ?? ''),
              //   ),
              // ),
              DataCell(Container(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: roundedElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(
                                table); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
                          },
                          text: "Sửa",
                          backgroundColor: Colors.yellow),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: roundedElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(
                                table); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
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
