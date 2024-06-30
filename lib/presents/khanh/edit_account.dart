import 'package:cake_coffee/models/khanh/roles.dart';
import 'package:cake_coffee/models/khanh/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditUserPage extends StatefulWidget {
  final Users user;
  final Function(Users) onUpdateUser;
  final Function(String) onDeleteUser;

  const EditUserPage({
    super.key,
    required this.user,
    required this.onUpdateUser,
    required this.onDeleteUser,
  });

  static Future<void> openEditUserDialog(
    BuildContext context,
    Users user,
    Function(Users) onUpdateUser,
    Function(String) onDeleteUser,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditUserPage(
          user: user,
          onUpdateUser: onUpdateUser,
          onDeleteUser: onDeleteUser,
        );
      },
    );
  }

  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  late TextEditingController _nameController;
  late TextEditingController _accountController;
  late TextEditingController _password1Controller;
  late TextEditingController _password2Controller;
  String _selectedRoleId = '';
  bool _isEditing = false;
  List<Roles> roles = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _accountController = TextEditingController(text: widget.user.account);
    _password1Controller = TextEditingController(text: widget.user.password1);
    _password2Controller = TextEditingController(text: widget.user.password2);
    _selectedRoleId = widget.user.id_role ?? '';
    loadRoles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _password1Controller.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  void loadRoles() async {
    try {
      List<Roles> fetchedRoles = await fetchRolesFromFirestore();
      setState(() {
        roles = fetchedRoles;
      });
    } catch (e) {
      print('Load categories failed: $e');
    }
  }

  void _editUser(String userId) async {
    setState(() {
      _isEditing = true;
    });

    String name = _nameController.text.trim();
    String account = _accountController.text.trim();
    String password1 = _password1Controller.text.trim();
    String password2 = _password2Controller.text.trim();

    try {
      Map<String, dynamic> updatedData = {
        'name': name,
        'account': account,
        'password1': password1,
        'password2': password2,
        'id_role': _selectedRoleId,
        'update_time': DateTime.now(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công!'),
        ),
      );

      setState(() {
        _isEditing = false;
        widget.user.name = name;
        widget.user.account = account;
        widget.user.password1 = password1;
        widget.user.password2 = password2;
        widget.user.id_role = _selectedRoleId;
        widget.user.update_time = DateTime.now();
      });

      widget.onUpdateUser(widget.user);

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thất bại'),
        ),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      widget.onDeleteUser(userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa thành công'),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa thất bại'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_isEditing) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thông báo'),
                  content:
                      const Text('Đang cập nhật tài khoản, vui lòng đợi...'),
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
        child: AlertDialog(
          title: const Text('Cập tài khoản người dùng'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: _selectedRoleId,
                  onChanged: _isEditing
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedRoleId = newValue ?? '';
                          });
                        },
                  items: roles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role.id,
                      child: Text(role.name),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _nameController,
                  enabled: !_isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Tên người dùng',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _accountController,
                  decoration: const InputDecoration(
                    labelText: 'Tài khoản',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isEditing,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _password1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu 1',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isEditing,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _password2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu 2',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isEditing,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _isEditing
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: const Text('Thoát'),
            ),
            ElevatedButton(
              onPressed: _isEditing ? null : () => _editUser(widget.user.id),
              child: _isEditing
                  ? const CircularProgressIndicator()
                  : const Text('Lưu'),
            ),
            ElevatedButton(
              onPressed: _isEditing ? null : () => _deleteUser(widget.user.id),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Xóa'),
            ),
          ],
        ));
  }
}
