import 'package:cake_coffee/models/khanh/roles.dart';
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
  List<Roles> roles = [];

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
        String password1 = user['password1'];
        String password2 = user['password2'];
        String roleId = user['id_role'];
        String userName = user['name']; // Lấy tên người dùng từ Firestore

        // Kiểm tra mật khẩu
        if (password1 == password || password2 == password) {
          // Lấy tên vai trò từ Firestore dựa vào id_role
          DocumentSnapshot roleSnapshot = await FirebaseFirestore.instance
              .collection('roles')
              .doc(roleId)
              .get();

          if (roleSnapshot.exists) {
            String roleName = roleSnapshot['name'];

            switch (roleName) {
              case 'Admin':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Management_Screen(adminName: userName),
                  ),
                );
                break;
              case 'NhanVien':
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => OrderScreenDesktop(nvName: userName),
                //   ),
                // );
                break;
              default:
                setState(() {
                  _errorMessage = 'Vai trò của bạn không hợp lệ';
                });
            }
          } else {
            setState(() {
              _errorMessage = 'Vai trò không tồn tại trong hệ thống';
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: MediaQuery.of(context).size.width,
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'ĐĂNG NHẬP',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Container(
//               color: Colors.amber,
//               width: MediaQuery.of(context).size.width * 0.3,
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: _nameController,
//                     decoration: const InputDecoration(
//                       labelText: 'Tài khoản',
//                       border: OutlineInputBorder(),
//                     ),
//                     enabled: !_isLoading,
//                   ),
//                   const SizedBox(height: 16.0),
//                   TextField(
//                     controller: _passwordController,
//                     decoration: const InputDecoration(
//                       labelText: 'Mật khẩu',
//                       border: OutlineInputBorder(),
//                     ),
//                     obscureText: true,
//                     enabled: !_isLoading,
//                   ),
//                   const SizedBox(height: 20),
//                   if (_errorMessage.isNotEmpty)
//                     Text(
//                       _errorMessage,
//                       style: const TextStyle(color: Colors.red),
//                       textAlign: TextAlign.center,
//                     ),
//                   const SizedBox(height: 20),
//                   _isLoading
//                       ? const CircularProgressIndicator()
//                       : ElevatedButton(
//                           onPressed: _login,
//                           child: const Text('Đăng nhập'),
//                         ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Đăng nhập'),
        // ),
        body: SizedBox(
      // color: Colors.amber,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //  crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              child: const Text(
            'ĐĂNG NHẬP',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          )),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      labelText: 'Tài khoản',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 10),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('Đăng nhập'),
                      ),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
