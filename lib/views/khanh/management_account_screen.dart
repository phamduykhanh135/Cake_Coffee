import 'package:cake_coffee/models/khanh/users.dart';

import 'package:cake_coffee/presents/khanh/add_user.dart';
import 'package:cake_coffee/presents/khanh/edit_account.dart';

import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:cake_coffee/views/customner_screen.dart';
import 'package:flutter/material.dart';

class Management_Account_Screen extends StatefulWidget {
  const Management_Account_Screen({super.key});

  @override
  _Management_Account_ScreenState createState() =>
      _Management_Account_ScreenState();
}

class _Management_Account_ScreenState extends State<Management_Account_Screen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchUserController = TextEditingController();
  String _searchUserQuery = '';
  late TabController _tabController;
  List<Users> users = [];

  void _onAddUser(Users newUser) {
    setState(() {
      users.add(newUser);
    });
  }

  void _deleteUserFromList(String userId) {
    setState(() {
      users.removeWhere((user) => user.id == userId);
    });
  }

  void _updateUserInList(Users updatedUser) {
    setState(() {
      int index = users.indexWhere((user) => user.id == updatedUser.id);
      if (index != -1) {
        users[index] = updatedUser;
      }
    });
  }

  List<Users> _filteredUsers() {
    List<Users> filtered =
        List.from(users); // Tạo một bản sao của danh sách users

    if (_searchUserQuery.isNotEmpty) {
      filtered = filtered
          .where((user) =>
              user.name
                  .toLowerCase()
                  .contains(_searchUserQuery.toLowerCase()) ||
              user.account
                  .toLowerCase()
                  .contains(_searchUserQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchUserController.addListener(() {
      setState(() {
        _searchUserQuery = _searchUserController.text;
      });
    });

    _tabController = TabController(length: 2, vsync: this);
    loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void loadUsers() async {
    List<Users> fetchedUsers = await fetchUsersFromFirestore();
    setState(() {
      users = fetchedUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey[200],
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Tài khoản nhân viên'),
                Tab(text: 'Tài khoản khách hàng'),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildUserTab(), const CustomerScreen()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông tin người dùng',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Container(
                child: roundedElevatedButton(
                  onPressed: () {
                    AddUserPage.openAddUserDialog(context, _onAddUser);
                  },
                  text: "Thêm",
                  backgroundColor: Colors.green.shade400,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const SizedBox(width: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: TextFormField(
                  controller: _searchUserController,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'Tìm kiếm người dùng',
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
                  _searchUserController.clear();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: _buildUserTable(),
          ),
        )
      ],
    );
  }

  Widget _buildUserTable() {
    List<Users> filteredUsers = _filteredUsers();
    return Column(
      children: [
        // Header row
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 3,
          child: Container(
            color: const Color.fromARGB(255, 207, 205, 205),
            margin: const EdgeInsets.all(0),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('STT'),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Tên người dùng'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Vai trò'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Tài khoản'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Ngày tạo'),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Scrollable rows
        Expanded(
          child: filteredUsers.isEmpty
              ? const Center(
                  child: Text('Không có tài khoản nào được tìm thấy!'),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: filteredUsers.asMap().entries.map((entry) {
                      int index = entry.key;
                      Users user = entry.value;
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        elevation: 3,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _openEditUserDialog(context, user),
                          child: Row(
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
                                  child: Text(user.name),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 15, 5, 15),
                                  child: Text(user.role),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user.account),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(_formatDate(user.created_at)),
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
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _openEditUserDialog(BuildContext context, Users user) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditUserPage(
          user: user,
          onUpdateUser: _updateUserInList,
          onDeleteUser: _deleteUserFromList, // Pass the callback
        );
      },
    );
  }
}
