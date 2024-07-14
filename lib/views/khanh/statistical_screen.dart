import 'package:cake_coffee/views/gop.dart';
import 'package:cake_coffee/views/khanh/revenue_statistics_screen.dart';
import 'package:cake_coffee/views/khanh/statistical_material_screen.dart';
import 'package:flutter/material.dart';

class Statistical_Screen extends StatefulWidget {
  const Statistical_Screen({super.key});

  @override
  State<Statistical_Screen> createState() => _Statistical_ScreenState();
}

class _Statistical_ScreenState extends State<Statistical_Screen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            //  width: MediaQuery.of(context).size.width * 0.3,
            color: Colors.grey[200],
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Thống kê danh thu'),
                Tab(text: 'Thốn kê nguồn vốn'),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  child: const Revenue_Statistics_Screen(),
                ),
                Container(
                  child: const Statistical_Material_Screen(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
