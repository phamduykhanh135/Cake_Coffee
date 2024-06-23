import 'package:cake_coffee/views/khanh/management_account_screen.dart';
import 'package:cake_coffee/views/khanh/management_ingredient_screen.dart';
import 'package:cake_coffee/views/khanh/management_product.dart';
import 'package:cake_coffee/views/khanh/management_table.dart';
import 'package:flutter/material.dart';

class Management_Screen extends StatefulWidget {
  const Management_Screen({super.key});

  @override
  State<Management_Screen> createState() => _Management_ScreenState();
}

class _Management_ScreenState extends State<Management_Screen> {
  bool _showProductManagement = false;
  bool _showTableManagement = false;
  bool _showIngredientManagement = false;
  bool _showAccountManagement = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Name Admin: Phạm Duy Khánh",
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE5BBBB),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Row(
              children: [
                Container(
                  color: Colors.green,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Column(
                    children: [
                      _elevenButton("Quản lý sản phẩm", () {
                        setState(() {
                          _showProductManagement = true;
                          _showTableManagement = false;
                          _showIngredientManagement = false;
                          _showAccountManagement = false;
                        });
                      }),
                      _elevenButton("Quản lý nguyên liệu", () {
                        setState(() {
                          _showIngredientManagement = true;
                          _showProductManagement = false;
                          _showTableManagement = false;
                          _showAccountManagement = false;
                        });
                      }),
                      _elevenButton("Quản lý bàn", () {
                        setState(() {
                          _showProductManagement = false;
                          _showTableManagement = true;
                          _showIngredientManagement = false;
                          _showAccountManagement = false;
                        });
                      }),
                      _elevenButton("Quản lý tài khoản", () {
                        setState(() {
                          _showProductManagement = false;
                          _showTableManagement = false;
                          _showIngredientManagement = false;
                          _showAccountManagement = true;
                        });
                      }),
                      _elevenButton("Quản  thống kê danh thu", () {}),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.grey,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Stack(
                    children: [
                      Visibility(
                        visible: _showProductManagement,
                        child:
                            const Management_Product(), // Show Management_Product if _showProductManagement is true
                      ),
                      Visibility(
                        visible: _showTableManagement,
                        child:
                            const Management_Table(), // Show Management_Table if _showTableManagement is true
                      ),
                      Visibility(
                        visible: _showIngredientManagement,
                        child:
                            const Management_Ingredient_Screen(), // Show Management_Product if _showProductManagement is true
                      ),
                      Visibility(
                        visible: _showAccountManagement,
                        child:
                            const Management_Account_Screen(), // Show Management_Product if _showProductManagement is true
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _elevenButton(String text, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // Rounded corners
            side: const BorderSide(
              color: Colors.grey,
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
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//   }
}
