import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_coffee/models/khanh/users.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _accountController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _accountController = TextEditingController(text: widget.user.account);
    _passwordController = TextEditingController();
    _confirmPasswordController =
        TextEditingController(); // Initialize _confirmPasswordController
  }

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool isPasswordValid(String password) {
    // Check length
    if (password.length < 8 || password.length > 15) {
      return false;
    }

    // Check uppercase letter
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

    // Check for special characters
    RegExp specialChars = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
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

  void _editUser(String userId) async {
    if (_isEditing) return;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String name = _nameController.text.trim();
      String account = _accountController.text.trim();
      String password = _passwordController.text.trim();
      String confirmPassword = _confirmPasswordController.text.trim();

      try {
        if (password != confirmPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mật khẩu xác nhận không khớp'),
            ),
          );
          setState(() {
            _isEditing = false;
          });
          return;
        }

        Map<String, dynamic> updatedData = {
          'name': name,
          'account': account,
          'password': password,
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
          widget.user.password = password;
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
  }

  void _deleteUser(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String userRole = userDoc.get('role');

        if (userRole == 'Admin') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể xóa tài khoản Admin'),
            ),
          );
          return;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();

        widget.onDeleteUser(userId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa thành công'),
          ),
        );

        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Người dùng không tồn tại'),
          ),
        );
      }
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
    return AlertDialog(
      title: const Text('Chỉnh sửa tài khoản người dùng'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên người dùng',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isEditing,
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
                enabled: !_isEditing,
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
                obscureText: !_showPassword,
                enabled: !_isEditing,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (!isPasswordValid(value)) {
                    return 'Mật khẩu phải từ 8-15 ký tự, có ít nhất 1 ký tự viết hoa và có ký tự đặc biệt';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                enabled: !_isEditing,
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
            iconColor: Colors.red,
            disabledIconColor: Colors.white,
          ),
          child: const Text('Xóa'),
        ),
      ],
    );
  }
}
