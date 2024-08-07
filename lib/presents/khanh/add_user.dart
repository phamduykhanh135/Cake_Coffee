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
        return AddUserPage(
          onAddUser: onAddUser,
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class _AddUserPageState extends State<AddUserPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool isValidPassword(String password) {
    if (password.length < 8 || password.length > 15) {
      return false;
    }

    bool hasUppercase = false;
    for (int i = 0; i < password.length; i++) {
      if (password[i].toUpperCase() == password[i] &&
          password[i].toLowerCase() != password[i]) {
        hasUppercase = true;
        break;
      }
    }
    if (!hasUppercase) {
      return false;
    }

    RegExp specialChars = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
    if (!specialChars.hasMatch(password)) {
      return false;
    }

    return true;
  }

  void _toggleShowPassword() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _toggleShowConfirmPassword() {
    setState(() {
      _showConfirmPassword = !_showConfirmPassword;
    });
  }

  void _addUser() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String name = _nameController.text.trim();
      String account = _accountController.text.trim();
      String password = _passwordController.text.trim();

      setState(() {
        _isLoading = true;
      });

      try {
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('users').add({
          'name': name,
          'account': account,
          'password': password,
          'role': "Nhân viên",
          'created_at': DateTime.now(),
        });

        Users newUser = Users(
          id: docRef.id,
          name: name,
          account: account,
          password: password,
          role: "Nhân viên",
          created_at: DateTime.now(),
        );

        widget.onAddUser(newUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm người dùng thành công!'),
          ),
        );

        _nameController.clear();
        _accountController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm người dùng thất bại: $error'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm tài khoản người dùng'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên người dùng',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên người dùng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _accountController,
                decoration: const InputDecoration(
                  labelText: 'Tài khoản',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tài khoản';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: _toggleShowPassword,
                  ),
                ),
                obscureText: !_showPassword,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (!isValidPassword(value)) {
                    return 'Mật khẩu phải từ 8-15 ký tự, có ít nhất 1 ký tự viết hoa và không có ký tự đặc biệt';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: _toggleShowConfirmPassword,
                  ),
                ),
                obscureText: !_showConfirmPassword,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập xác nhận mật khẩu';
                  }
                  if (value != _passwordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: _isLoading ? null : _addUser,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Thêm người dùng'),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _isLoading ? null : widget.onCancel,
          child: const Text('Thoát'),
        ),
      ],
    );
  }
}
