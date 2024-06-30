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
        backgroundColor: const Color(0xFFE5BBBB),
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
                _elevenButton("Quản thống kê danh thu", 4),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                const Management_Product(),
                const Management_Ingredient_Screen(),
                const Management_Table(),
                const Management_Account_Screen(),
                Container(
                    // Placeholder for "Quản thống kê danh thu"
                    alignment: Alignment.center,
                    child: Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/datn-628de.appspot.com/o/product_images%2F1719240663130.jpeg?alt=media&token=4477fbbc-c199-4d53-8163-f626f60564b3',
                      width: 50,
                      height: 50,
                    )),
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
