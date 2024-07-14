import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:cake_coffee/views/demo.dart';
import 'package:cake_coffee/views/khanh/management_screen.dart';
import 'package:cake_coffee/views/oder_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String account = _nameController.text;
    String password = _passwordController.text;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('account', isEqualTo: account)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var user = querySnapshot.docs.first;
        String password1 = user['password'];
        String role = user['role'];
        String userName = user['name'];

        if (password1 == password) {
          switch (role) {
            case 'Admin':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Management_Screen(adminName: userName),
                ),
              );
              break;
            case 'Nhân viên':
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderScreenDesktop(nvName: userName),
                ),
              );
              break;
            default:
              setState(() {
                _errorMessage = 'Vai trò của bạn không hợp lệ';
              });
          }
        } else {
          setState(() {
            _errorMessage = 'Mật khẩu không đúng';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Tài khoản không tồn tại';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Đã xảy ra lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/login.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.grey.withOpacity(0.6),
            BlendMode.dstATop,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              child: Text(
            'Cake & Coffee',
            style: TextStyle(
              color: Colors.brown.shade800,
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          )),
          const SizedBox(height: 100),
          Container(
              child: Text(
            'Đăng nhập',
            style: TextStyle(
              color: Colors.brown.shade800,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          )),
          const SizedBox(height: 50),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Tài khoản',
                      labelStyle: TextStyle(color: Colors.grey[800]),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.brown.shade800),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.brown.shade800),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      labelStyle: TextStyle(color: Colors.grey[800]),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.brown.shade800),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.brown.shade800),
                      ),
                    ),
                    obscureText: true,
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(height: 10),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: MediaQuery.of(context).size.width * 0.19,
                        height: 50,
                        child: roundedElevatedButton(
                            onPressed:
                                //  () {
                                // //   Navigator.pushReplacement(
                                // //     context,
                                // //     MaterialPageRoute(
                                // //       builder: (context) =>
                                // //           const Demo(nvName: "dasdas"),
                                // //     ),
                                // //   );
                                // // },

                                _login,
                            text: 'Đăng nhập',
                            backgroundColor: Colors.green.shade300),
                      )
              ],
            ),
          )
        ],
      ),
    ));
  }
}
