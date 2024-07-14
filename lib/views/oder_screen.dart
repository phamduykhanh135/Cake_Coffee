import 'package:cake_coffee/views/carry_away_screen.dart';
import 'package:cake_coffee/views/demo.dart';
import 'package:cake_coffee/views/in_place_screen.dart';
import 'package:cake_coffee/views/khanh/login_screen.dart';
import 'package:flutter/material.dart';

class OrderScreenDesktop extends StatefulWidget {
  final String nvName;
  const OrderScreenDesktop({super.key, required this.nvName});

  @override
  _OrderScreenDesktopState createState() => _OrderScreenDesktopState();
}

class _OrderScreenDesktopState extends State<OrderScreenDesktop> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2, // Number of tabs
        child: Scaffold(
            appBar: AppBar(
                title: const TabBar(
                  labelColor: Colors.black, // Màu chữ khi tab được chọn
                  unselectedLabelColor:
                      Colors.white, // Màu chữ khi tab không được chọn
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold, // Tô đậm chữ khi tab được chọn
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight:
                        FontWeight.normal, // Chữ thường khi tab không được chọn
                  ),

                  tabs: [
                    Tab(
                      child: Text(
                        'Tại chỗ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Tô đậm
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Mang về',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Tô đậm
                        ),
                      ),
                    ),
                  ],
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
                backgroundColor:
                    Colors.green.shade400 //const Color(0xFFE5BBBB),
                ),
            body: TabBarView(
              children: [
                Container(child: Demo(nvName: widget.nvName)),
                Container(child: Carry_Away(nvName: widget.nvName)),
              ],
            )));
  }
}
