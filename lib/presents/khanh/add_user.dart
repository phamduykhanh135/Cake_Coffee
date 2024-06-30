import 'package:cake_coffee/models/khanh/roles.dart';
import 'package:cake_coffee/models/khanh/users.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserPage extends StatefulWidget {
  final Function(Users) onAddUser;
  final VoidCallback onCancel;

  const AddUserPage({
    super.key,
    required this.onAddUser,
    required this.onCancel,
  });

  @override
  _AddUserPageState createState() => _AddUserPageState();

  static Future<void> openAddUserDialog(
    BuildContext context,
    Function(Users) onAddUser,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm người dùng'),
          content: AddUserPage(
            onAddUser: onAddUser,
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _password1Controller = TextEditingController();
  final TextEditingController _password2Controller = TextEditingController();
  String _selectedRoleId = '';
  List<Roles> roles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadRoles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _password1Controller.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  void loadRoles() async {
    List<Roles> fetchedRoles = await fetchRolesFromFirestore();
    setState(() {
      roles = fetchedRoles;
    });
  }

  void _addUser() async {
    if (_isLoading || !mounted) return;

    String name = _nameController.text.trim();
    String account = _accountController.text.trim();
    String password1 = _password1Controller.text.trim();
    String password2 = _password2Controller.text.trim();

    if (name.isNotEmpty &&
        password1.isNotEmpty &&
        password2.isNotEmpty &&
        _selectedRoleId.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('users').add({
          'name': name,
          'account': account,
          'password1': password1,
          'password2': password2,
          'id_role': _selectedRoleId,
          'create_time': DateTime.now(),
          'update_time': null,
          'delete_time': null,
        });

        Users newUser = Users(
          id: docRef.id,
          name: name,
          account: account,
          password1: password1,
          password2: password2,
          id_role: _selectedRoleId,
          create_time: DateTime.now(),
          update_time: null,
          delete_time: null,
        );

        widget.onAddUser(newUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm người dùng thành công!'),
          ),
        );

        _nameController.clear();
        _accountController.clear();
        _password1Controller.clear();
        _password2Controller.clear();
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm người dùng thất bại: $error'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin người dùng.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_isLoading) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thông báo'),
                  content: const Text('Đang thêm tài khoản, vui lòng đợi...'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Đồng ý'),
                    ),
                  ],
                );
              },
            );
            return false; // Prevent back navigation if loading
          }
          return true;
        },
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedRoleId.isEmpty ? null : _selectedRoleId,
                  onChanged: _isLoading
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedRoleId = newValue ?? '';
                          });
                        },
                  items: roles.map((role) {
                    return DropdownMenuItem(
                      value: role.id,
                      child: Text(role.name),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Vai trò',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên người dùng',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _accountController,
                  decoration: const InputDecoration(
                    labelText: 'Tài khoản',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _password1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu 1',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _password2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu 2',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addUser,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Thêm người dùng'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : widget.onCancel,
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ),
        ));
  }
}
