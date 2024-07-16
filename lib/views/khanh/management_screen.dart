import 'package:cake_coffee/views/customner_screen.dart';
import 'package:cake_coffee/views/khanh/login_screen.dart';
import 'package:cake_coffee/views/khanh/statistical_screen.dart';
import 'package:flutter/material.dart';
import 'package:cake_coffee/views/khanh/management_account_screen.dart';
import 'package:cake_coffee/views/khanh/management_ingredient_screen.dart';
import 'package:cake_coffee/views/khanh/management_product.dart';
import 'package:cake_coffee/views/khanh/management_table.dart';

class Management_Screen extends StatefulWidget {
  final String adminName;
  const Management_Screen({super.key, required this.adminName});

  @override
  State<Management_Screen> createState() => _Management_ScreenState();
}

class _Management_ScreenState extends State<Management_Screen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Quản lý: ${widget.adminName}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.red.shade400,
                ))
          ],
          backgroundColor: Colors.green.shade400 // const Color(0xFFE5BBBB),
          ),
      body: Row(
        children: [
          Container(
            color: const Color.fromARGB(255, 214, 212, 212),
            width: MediaQuery.of(context).size.width * 0.2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _elevenButton("Quản lý sản phẩm", 0),
                _elevenButton("Quản lý nguyên liệu", 1),
                _elevenButton("Quản lý bàn", 2),
                _elevenButton("Quản lý tài khoản", 3),
                _elevenButton("Quản thống kê", 4),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                Management_Product(),
                Management_Ingredient_Screen(),
                Management_Table(),
                Management_Account_Screen(),
                Statistical_Screen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _elevenButton(String text, int index) {
    bool isSelected = _selectedIndex == index;
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // Rounded corners
            side: BorderSide(
              color: isSelected ? Colors.white : Colors.grey,
              width: 2, // Border width and color
            ),
          ),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.17,
          height: MediaQuery.of(context).size.height * 0.06,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
