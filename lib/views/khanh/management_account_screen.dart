import 'package:cached_network_image/cached_network_image.dart';
import 'package:cake_coffee/models/khanh/roles.dart';
import 'package:cake_coffee/models/khanh/users.dart';
import 'package:cake_coffee/presents/khanh/add_roles.dart';
import 'package:cake_coffee/presents/khanh/add_user.dart';
import 'package:cake_coffee/presents/khanh/edit_account.dart';
import 'package:cake_coffee/presents/khanh/edit_role.dart';
import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _searchRoleController = TextEditingController();
  String _searchUserQuery = '';
  String _searchRoleQuery = '';
  String _selectedRoleId = '';
  late TabController _tabController;
  List<Roles> roles = [];
  List<Users> users = [];

  void _onAddUser(Users newUser) {
    setState(() {
      users.add(newUser);
    });
  }

  void _onAddRole(Roles newRole) {
    setState(() {
      roles.add(newRole);
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

  void _deleteRoleFromList(String roleId) {
    setState(() {
      roles.removeWhere((role) => role.id == roleId);
    });
  }

  void _updateRoleInList(Roles updatedRole) {
    setState(() {
      int index = roles.indexWhere((role) => role.id == updatedRole.id);
      if (index != -1) {
        roles[index] = updatedRole;
      }
    });
  }

  List<Roles> _filteredRoles() {
    List<Roles> filtered = roles;

    if (_searchRoleQuery.isNotEmpty) {
      filtered = filtered
          .where((role) =>
              role.name.toLowerCase().contains(_searchRoleQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  List<Users> _filteredUsers() {
    List<Users> filtered = users;

    if (_searchUserQuery.isNotEmpty) {
      filtered = filtered
          .where((user) =>
              user.name.toLowerCase().contains(_searchUserQuery.toLowerCase()))
          .toList();
    }

    if (_selectedRoleId.isNotEmpty) {
      filtered =
          filtered.where((user) => user.id_role == _selectedRoleId).toList();
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

    _searchRoleController.addListener(() {
      setState(() {
        _searchRoleQuery = _searchRoleController.text;
      });
    });
    _tabController = TabController(length: 2, vsync: this);
    loadRoles();
    loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void loadRoles() async {
    List<Roles> fetchedRoles = await fetchRolesFromFirestore();
    setState(() {
      roles = fetchedRoles;
    });
  }

  void loadUsers() async {
    List<Users> fetchedUsers = await fetchUsersFromFirestore();
    setState(() {
      users = fetchedUsers;
    });
  }

  String _getRoleNameById(String roleId) {
    final role = roles.firstWhere(
      (role) => role.id == roleId,
      orElse: () => Roles(
        id: 'unknown',
        name: 'Unknown',
        create_time: DateTime.now(),
        update_time: DateTime.now(),
        delete_time: DateTime.now(),
      ),
    );
    return role.name;
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
                Tab(text: 'Người dùng'),
                Tab(text: 'Vai trò'),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserTab(),
                _buildRoleTab(),
              ],
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
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                child: DropdownButtonFormField<String>(
                  value: _selectedRoleId.isEmpty ? '' : _selectedRoleId,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRoleId = newValue ?? '';
                    });
                  },
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Tất cả'),
                    ),
                    ...roles.map((role) {
                      return DropdownMenuItem(
                        value: role.id,
                        child: Text(role.name),
                      );
                    }),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Vai trò',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
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

  Widget _buildRoleTab() {
    return SizedBox(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông tin vai trò',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Container(
                  child: roundedElevatedButton(
                    onPressed: () {
                      AddRolePage.openAddRoleDialog(context, _onAddRole);
                    },
                    text: "Thêm",
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: TextFormField(
                    controller: _searchRoleController,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      labelText: 'Tìm kiếm vai trò',
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
                    _searchRoleController.clear();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildRoleTable(), // Đặt _buildCategoryTable() ở đây
              ),
            ),
          ),
        ],
      ),
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
                    child: Text('Tài khoản'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Text('Vai trò'),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Scrollable rows
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: filteredUsers.asMap().entries.map((entry) {
                int index = entry.key;
                Users user = entry.value;
                final roleName = _getRoleNameById(user.id_role);

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
                            padding: const EdgeInsets.all(8.0),
                            child: Text(user.account),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(roleName),
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

  Widget _buildRoleTable() {
    List<Roles> filteredRoles = _filteredRoles();
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        children: [
          // Header row
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 3,
            child: Container(
              color: const Color.fromARGB(255, 207, 205, 205),
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
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                      child: Text('Tên vai trò'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scrollable rows
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: filteredRoles.asMap().entries.map((entry) {
                  int index = entry.key;
                  Roles role = entry.value;
                  return Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        elevation: 3,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _openEditRooleDialog(context, role),
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
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(role.name),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
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

  void _openEditRooleDialog(BuildContext context, Roles roles) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditRolePage(
          role: roles,
          onUpdateRole: _updateRoleInList,
          onDeleteRole: _deleteRoleFromList, // Pass the callback
        );
      },
    );
  }
}
