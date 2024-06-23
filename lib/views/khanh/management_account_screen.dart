import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:flutter/material.dart';

class Management_Account_Screen extends StatefulWidget {
  const Management_Account_Screen({super.key});

  @override
  State<Management_Account_Screen> createState() =>
      _Management_Account_ScreenState();
}

class _Management_Account_ScreenState extends State<Management_Account_Screen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> accounts = [
    {
      'id': '001',
      'name': 'Pham Duy Khanh',
      'password1': '34545435',
      'password2': '321511',
      'id_role': 'R1'
    },
    {
      'id': '002',
      'name': 'Pham Dang Khoi',
      'password1': '34545435',
      'password2': '321511',
      'id_role': 'R2'
    },
    {
      'id': '003',
      'name': 'Nguyen Thi Yen Nhi',
      'password1': '34545435',
      'password2': '321511',
      'id_role': 'R2'
    },
    {
      'id': '004',
      'name': 'Nguyen Thi Ai Vy',
      'password1': '34545435',
      'password2': '321511',
      'id_role': 'R2'
    },
    {
      'id': '005',
      'name': 'Phan Duy Khang',
      'password1': '34545435',
      'password2': '321511',
      'id_role': 'R2'
    },
    {
      'id': '006',
      'name': 'Phan van Ky',
      'password1': '34545435',
      'password2': '321511',
      'id_role': 'R2'
    },
    {
      '      id': '007',
      'name': 'Pham Nhat Long',
      'password1': '34545435',
      'password2': '321511',
      'id_role': 'R2'
    }
  ];
  final List<Map<String, String>> roless = [
    {'id': 'R1', 'name': 'Admin'},
    {'id': 'R2', 'name': 'Nhan Vien'},
  ];
  String _getRoleNameId(String roleId) {
    final roles = roless.firstWhere(
      (roles) => roles['id'] == roleId,
      orElse: () => {'name': 'Unknown'},
    );
    return roles['name'] ?? 'Unknown';
  }

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

  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            child: Column(
              children: [
                TabBar(controller: _tabController, tabs: const [
                  Tab(
                    text: "Tài khoản",
                  ),
                  Tab(
                    text: "Vai trò",
                  )
                ])
              ],
            ),
          ),
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: [
              _account(),
              _role(),
            ],
          ))
        ],
      ),
    );
  }

  Widget _role() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Row(
            children: [Text('Thông tin danh mục')],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 30,
                      child: TextFormField(
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {},
                    )
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
              width: MediaQuery.of(context).size.width, child: _buildRole()),
        ],
      ),
    );
  }

  Widget _account() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [Text("Thông tin tài khoản")],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: 30,
                      child: TextFormField(
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {},
                    )
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
              width: MediaQuery.of(context).size.width, child: _buildAccount()),
        ],
      ),
    );
  }

  Widget _buildRole() {
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
        rows: roless.map((role) {
          return DataRow(
            cells: [
              DataCell(Text(role['id'] ?? '')),
              DataCell(Text(role['name'] ?? '')),
              DataCell(Container(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: roundedElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(
                                role); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
                          },
                          text: "Sửa",
                          backgroundColor: Colors.yellow),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: roundedElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(
                                role); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
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

  Widget _buildAccount() {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 3,
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Mã tài khoản")),
            DataColumn(label: Text("Tên tài khoản")),
            DataColumn(label: Text("Password 1")),
            DataColumn(label: Text("Password 2")),
            DataColumn(label: Text("Vai trò")),
            DataColumn(label: Text("Thao tác")),
          ],
          rows: List<DataRow>.generate(accounts.length, (index) {
            var account = accounts[index];
            return DataRow(cells: [
              DataCell(
                Text(account['id'] ?? ''),
              ),
              DataCell(Text(account['name'] ?? '')),
              DataCell(Text(account['password1'] ?? '')),
              DataCell(Text(account['password2'] ?? '')),
              DataCell(Text(_getRoleNameId(account['id_role'] ?? ''))),
              DataCell(Container(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: roundedElevatedButton(
                          onPressed: () {
                            _showOptionsDialog(
                                account); // Hiển thị dialog tùy chọn khi nhấn vào DataRow
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
            ]);
          }),
        ));
  }
}
