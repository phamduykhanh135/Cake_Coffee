import 'package:cake_coffee/models/khanh/customers.dart';
import 'package:cake_coffee/models/khanh/users.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AddCustomers extends StatefulWidget {
  final Function(Customers) onAddCustomer;
  final VoidCallback onCancel;

  const AddCustomers({
    super.key,
    required this.onAddCustomer,
    required this.onCancel,
  });

  @override
  _AddCustomersPageState createState() => _AddCustomersPageState();

  static Future<void> openAddCustomerDialog(
    BuildContext context,
    Function(Customers) onAddCustomer,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCustomers(
          onAddCustomer: onAddCustomer,
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class _AddCustomersPageState extends State<AddCustomers> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pointControllerr = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _pointControllerr.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool isValidPassword(String password) {
    if (password.length < 8 || password.length > 15) {
      return false;
    }

    bool hasUppercase = false;
    bool hasLowercase = false;
    for (int i = 0; i < password.length; i++) {
      if (password[i] == password[i].toUpperCase()) {
        hasUppercase = true;
      } else if (password[i] == password[i].toLowerCase()) {
        hasLowercase = true;
      }
    }
    if (!hasUppercase || !hasLowercase) {
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

  // void _addCustomer() async {
  //   if (_isLoading) return;

  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();
  //     int point = int.tryParse(_pointControllerr.text.trim()) ?? 0;

  //     String name = _nameController.text.trim();
  //     String password = _passwordController.text.trim();
  //     String phone = _phoneController.text.trim();

  //     setState(() {
  //       _isLoading = true;
  //     });

  //     try {
  //       await FirebaseFirestore.instance
  //           .collection('customers')
  //           .doc(phone) // Sử dụng số điện thoại làm id
  //           .set({
  //         'name': name,
  //         'password': password,
  //         'point': point,
  //         'phone': phone,
  //         'created_at': DateTime.now(),
  //       });

  //       Customers newCustomer = Customers(
  //         id: phone,
  //         name: name,
  //         password: password,
  //         point: point,
  //         phone: phone,
  //         created_at: DateTime.now(),
  //       );

  //       widget.onAddCustomer(newCustomer);

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Đã thêm khách hàng thành công!'),
  //         ),
  //       );
  //       _pointControllerr.clear();
  //       _nameController.clear();
  //       _passwordController.clear();
  //       _confirmPasswordController.clear();
  //       _phoneController.clear(); // Xóa luôn giá trị của số điện thoại sau khi thêm thành công
  //     } catch (error) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Thêm khách hàng thất bại: $error'),
  //         ),
  //       );
  //     } finally {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }
  void _addCustomer() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      int point = int.tryParse(_pointControllerr.text.trim()) ?? 0;

      String name = _nameController.text.trim();
      String password = _passwordController.text.trim();
      String phone = _phoneController.text.trim();

      setState(() {
        _isLoading = true;
      });

      try {
        print('Adding customer with phone: $phone');

        final customerDoc =
            FirebaseFirestore.instance.collection('customers').doc(phone);

        await customerDoc.set({
          'name': name,
          'password': password,
          'point': point,
          'phone': phone,
          'created_at': DateTime.now(),
        });

        final docSnapshot = await customerDoc.get();

        if (docSnapshot.exists) {
          // Kiểm tra lại dữ liệu
          print('Customer added with ID: ${docSnapshot.id}');
          print('Customer data: ${docSnapshot.data()}');
        } else {
          print('Failed to add customer. Document does not exist.');
        }

        Customers newCustomer = Customers(
          id: phone,
          name: name,
          password: password,
          point: point,
          phone: phone,
          created_at: DateTime.now(),
        );

        widget.onAddCustomer(newCustomer);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm khách hàng thành công!'),
          ),
        );
        _pointControllerr.clear();
        _nameController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _phoneController.clear();
      } catch (error) {
        print('Error adding customer: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm khách hàng thất bại: $error'),
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
      title: const Text('Thêm tài khoản khách hàng'),
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
                  labelText: 'Tên khách hàng',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên khách hàng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                enabled: !_isLoading,
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
                controller: _pointControllerr,
                decoration: const InputDecoration(
                  labelText: 'Điểm',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                enabled: !_isLoading,
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
          onPressed: _isLoading ? null : _addCustomer,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Thêm khách hàng'),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _isLoading ? null : widget.onCancel,
          child: const Text('Hủy'),
        ),
      ],
    );
  }
}
