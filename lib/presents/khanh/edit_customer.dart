import 'package:cake_coffee/models/khanh/customers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_coffee/models/khanh/users.dart';
import 'package:flutter/services.dart';

class EditCustomerPage extends StatefulWidget {
  final Customers customers;
  final Function(Customers) onUpdateCustomer;
  final Function(String) onDeleteCustomer;

  const EditCustomerPage({
    super.key,
    required this.customers,
    required this.onUpdateCustomer,
    required this.onDeleteCustomer,
  });

  static Future<void> openEditUserDialog(
    BuildContext context,
    Customers customers,
    Function(Customers) onUpdateCustomer,
    Function(String) onDeleteCustomer,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCustomerPage(
          customers: customers,
          onUpdateCustomer: onUpdateCustomer,
          onDeleteCustomer: onDeleteCustomer,
        );
      },
    );
  }

  @override
  _EditCustomerPageState createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phonetController;
  late TextEditingController _pointtController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customers.name);
    _phonetController = TextEditingController(text: widget.customers.phone);
    _pointtController =
        TextEditingController(text: widget.customers.point.toString());
    _passwordController = TextEditingController();
    _confirmPasswordController =
        TextEditingController(); // Initialize _confirmPasswordController
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phonetController.dispose();
    _pointtController.dispose();
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
      int point = int.tryParse(_pointtController.text.trim()) ?? 0;
      String phone = _phonetController.text.trim();
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
          'point': point,
          'name': name,
          'phone': phone,
          'password': password,
        };

        await FirebaseFirestore.instance
            .collection('customers')
            .doc(userId)
            .update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thành công!'),
          ),
        );

        setState(() {
          _isEditing = false;
          widget.customers.name = name;
          widget.customers.phone = phone;
          widget.customers.point = point;
          widget.customers.password = password;
        });

        widget.onUpdateCustomer(widget.customers);

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
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .delete();

      widget.onDeleteCustomer(userId);

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
                controller: _phonetController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                enabled: !_isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (value.length != 10) {
                    return 'Số điện thoại phải có đúng 10 chữ số';
                  }
                  if (!value.startsWith('03') &&
                      !value.startsWith('07') &&
                      !value.startsWith('09') &&
                      !value.startsWith('02')) {
                    return 'Số điện thoại phải bắt đầu bằng 03, 07, 09, 02';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _pointtController,
                decoration: const InputDecoration(
                  labelText: 'Điểm',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                enabled: !_isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập điểm';
                  }
                  if (value.length > 5) {
                    return 'Điểm tối đa 5 chữ số';
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
          onPressed: _isEditing ? null : () => _editUser(widget.customers.id),
          child: _isEditing
              ? const CircularProgressIndicator()
              : const Text('Lưu'),
        ),
        ElevatedButton(
          onPressed: _isEditing ? null : () => _deleteUser(widget.customers.id),
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
