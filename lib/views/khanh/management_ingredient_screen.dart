import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:flutter/material.dart'; // Import your Management_Product widget here

class Management_Ingredient_Screen extends StatefulWidget {
  const Management_Ingredient_Screen({super.key});

  @override
  _Management_Ingredient_Screen createState() =>
      _Management_Ingredient_Screen();
}

class _Management_Ingredient_Screen extends State<Management_Ingredient_Screen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> category_ingredidents = [
    {
      'id': '001',
      'name': 'Nguyên liệu',
    },
    {
      'id': '002',
      'name': 'Dụng cụ',
    },
  ];

  final List<Map<String, String>> ingredidents = [
    {
      'id': 'P001',
      'category_ingredidents_Id': '001',
      'name': 'Bột mì',
      'unit': 'kg',
      'number': '20',
      'price': '12.000đ',
      'description': 'Không có',
    },
    {
      'id': 'P001',
      'category_ingredidents_Id': '002',
      'name': 'Ly',
      'unit': 'kg',
      'number': '20',
      'price': '12.000đ',
      'description': 'Không có',
    },
    {
      'id': 'P001',
      'category_ingredidents_Id': '001',
      'name': 'Bột mì',
      'unit': 'kg',
      'number': '20',
      'price': '12.000đ',
      'description': 'Không có',
    },
  ];
  String _getCategoryNameById(String categoryId) {
    final category = category_ingredidents.firstWhere(
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
                    Tab(text: 'Nguyên liệu'), // First tab: Products
                    Tab(text: 'Danh mục'), // Second tab: Categories
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
                _ingredidents(), // Content for Products tab
                _category()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ingredidents() {
    return Container(
        padding: const EdgeInsets.all(10),
        // Placeholder for Categories tab content, replace with your actual implementation
        child: Column(
          children: [
            const Row(
              children: [
                Text(
                  'Thông tin nguyên liệu',
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
                child: _buildIngredientTable()),
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
                child: _buildCategory_Ingredient()),
          ],
        ));
  }

  Widget _buildCategory_Ingredient() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 3,
      child: DataTable(
        // columnSpacing: 343, // Điều chỉnh khoảng cách giữa các cột
        // horizontalMargin: 200, // Điều chỉnh margin ngang của DataTable
        columns: const [
          DataColumn(
            label: Text('Mã danh mục',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Tên danh mục',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label:
                Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: category_ingredidents.map((category) {
          return DataRow(
            cells: [
              DataCell(Text(category['id'] ?? '')),
              DataCell(Text(category['name'] ?? '')),
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

  Widget _buildIngredientTable() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 3,
      child: DataTable(
        //columnSpacing: 185,
        columns: const [
          DataColumn(
            label: Text(
              'Mã nguyên liệu',
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
            label: Text(
              'Tên',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Đơn vị',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Số lượng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Giá',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text('Tổng giá  ',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Ghi chú  ',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Thao tác  ',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: List<DataRow>.generate(ingredidents.length, (index) {
          var ingredient = ingredidents[index];

          // Parse number and price fields
          double? unitPrice = double.tryParse(
            ingredient['price']?.replaceAll('đ', '').replaceAll(',', '') ??
                '0.0',
          );

          int? number = int.tryParse(ingredient['number'] ?? '0');

          // Calculate total price as integer
          int totalPrice = (unitPrice ?? 0.0).toInt() * (number ?? 0);
          String totalPriceString = '$totalPrice.000đ'; // Append .000đ

          return DataRow(
            cells: [
              DataCell(Text(ingredient['id'] ?? '')),
              DataCell(
                Text(
                  _getCategoryNameById(
                      ingredient['category_ingredidents_Id'] ?? ''),
                ),
              ),
              DataCell(Text(ingredient['name'] ?? '')),
              DataCell(Text(ingredient['unit'] ?? '')),
              DataCell(Text(ingredient['number'] ?? '')),
              DataCell(Text(ingredient['price'] ?? '')),
              DataCell(Text(totalPriceString)),
              DataCell(Text(ingredient['description'] ?? '')),
              // DataCell(
              //   Text(
              //     _getCategoryNameById(product['categoryId'] ?? ''),
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
                                ingredient); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
                          },
                          text: "Sửa",
                          backgroundColor: Colors.yellow),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                    //   child: roundedElevatedButton(
                    //       onPressed: () {
                    //         _showOptionsDialog(
                    //             ingredient); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
                    //       },
                    //       text: "Xóa",
                    //       backgroundColor: Colors.red),
                    // ),
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
