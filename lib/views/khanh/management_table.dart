import 'package:cake_coffee/models/khanh/area.dart';
import 'package:cake_coffee/models/khanh/table.dart';
import 'package:cake_coffee/presents/khanh/add_area.dart';
import 'package:cake_coffee/presents/khanh/add_table.dart';
import 'package:cake_coffee/presents/khanh/edit_area.dart';
import 'package:cake_coffee/presents/khanh/edit_table.dart';
import 'package:cake_coffee/presents/khanh/resuable_widget.dart';
import 'package:flutter/material.dart';

class Management_Table extends StatefulWidget {
  const Management_Table({super.key});

  @override
  _Management_TableState createState() => _Management_TableState();
}

class _Management_TableState extends State<Management_Table>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchTableController = TextEditingController();
  final TextEditingController _searchAreaController = TextEditingController();
  String _searchTableQuery = '';
  String _searchAreaQuery = '';
  String _selectedAreaId = '';
  late TabController _tabController;
  List<Area> areas = [];
  List<Tables> tables = [];

  void _onAddTable(Tables newTable) {
    setState(() {
      tables.add(newTable);
    });
  }

  void _onAddArea(Area newArea) {
    setState(() {
      areas.add(newArea);
    });
  }

  void _deleteTableFromList(String tableId) {
    setState(() {
      tables.removeWhere((table) => table.id == tableId);
    });
  }

  void _updateTableInList(Tables updatedTable) {
    setState(() {
      int index = tables.indexWhere((table) => table.id == updatedTable.id);
      if (index != -1) {
        tables[index] = updatedTable;
      }
    });
  }

  void _deleteAreaFromList(String areaId) {
    setState(() {
      areas.removeWhere((area) => area.id == areaId);
    });
  }

  void _updateAreaInList(Area updatedArea) {
    setState(() {
      int index = areas.indexWhere((area) => area.id == updatedArea.id);
      if (index != -1) {
        areas[index] = updatedArea;
      }
    });
  }

  List<Area> _filteredAreas() {
    List<Area> filtered = areas;

    if (_searchAreaQuery.isNotEmpty) {
      filtered = filtered
          .where((area) =>
              area.name.toLowerCase().contains(_searchAreaQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  List<Tables> _filteredTables() {
    List<Tables> filtered = tables;

    if (_searchTableQuery.isNotEmpty) {
      filtered = filtered
          .where((table) => table.name
              .toLowerCase()
              .contains(_searchTableQuery.toLowerCase()))
          .toList();
    }

    if (_selectedAreaId.isNotEmpty) {
      filtered =
          filtered.where((table) => table.id_area == _selectedAreaId).toList();
    }

    return filtered;
  }

  @override
  void initState() {
    //Cập nhật trạng thái của _searchQuery khi người dùng nhập liệu:

    super.initState();
    _searchTableController.addListener(() {
      setState(() {
        _searchTableQuery = _searchTableController.text;
      });
    });

    _searchAreaController.addListener(() {
      setState(() {
        _searchAreaQuery = _searchAreaController.text;
      });
    });
    _tabController = TabController(length: 2, vsync: this);
    loadAreas();
    loadTables();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void loadAreas() async {
    List<Area> fetchedAreas = await fetchAreasFromFirestore();
    setState(() {
      areas = fetchedAreas;
    });
  }

  void loadTables() async {
    List<Tables> fetchedTables = await fetchTablesFromFirestore();
    setState(() {
      tables = fetchedTables;
    });
  }

  String _getAreaNameById(String areaId) {
    final area = areas.firstWhere(
      (area) => area.id == areaId,
      orElse: () => Area(
        id: 'unknown',
        name: 'Unknown',
        create_time: DateTime.now(),
        update_time: DateTime.now(),
        delete_time: DateTime.now(),
      ),
    );
    return area.name;
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
                Tab(text: 'Bàn'),
                Tab(text: 'Khu vực'),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTableTab(),
                _buildAreaTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thông tin bàn',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Container(
                child: roundedElevatedButton(
                  onPressed: () {
                    AddTablePage.openAddTableDialog(context, _onAddTable);
                  },
                  text: "Thêm",
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                child: DropdownButtonFormField<String>(
                  value: _selectedAreaId.isEmpty ? '' : _selectedAreaId,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedAreaId = newValue ?? '';
                    });
                  },
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Tất cả'),
                    ),
                    ...areas.map((area) {
                      return DropdownMenuItem(
                        value: area.id,
                        child: Text(area.name),
                      );
                    }),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Khu vực',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: TextFormField(
                  controller: _searchTableController,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'Tìm kiếm bàn',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  _searchTableController.clear();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: _buildTableTable(),
          ),
        )
      ],
    );
  }

  Widget _buildAreaTab() {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Đảm bảo căn lề bắt đầu từ đầu dòng
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông tin khu vực',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Container(
                  child: roundedElevatedButton(
                    onPressed: () {
                      Add_Area.openAdd_Area(context, _onAddArea);
                    },
                    text: "Thêm",
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: TextFormField(
                    controller: _searchAreaController,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      labelText: 'Tìm kiếm khu vực',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    _searchAreaController.clear();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildAreaTable(), // Đặt _buildCategoryTable() ở đây
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaTable() {
    List<Area> filteredCAreas = _filteredAreas();
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        children: [
          // Header row
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 3,
            child: Container(
              color: const Color.fromARGB(255, 207, 205, 205),
              child: const Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                      child: Text('STT'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                      child: Text('Tên khu vực'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scrollable rows
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: filteredCAreas.asMap().entries.map((entry) {
                  int index = entry.key;
                  Area area = entry.value;
                  return Column(
                    children: [
                      Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          elevation: 3,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _openEditAreaDialog(context, area),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('${index + 1}'),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(area.name),
                                  ),
                                ),
                              ],
                            ),
                          ))
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableTable() {
    List<Tables> filteredTables = _filteredTables();
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        children: [
          // Header row
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 3,
            child: Container(
              color: const Color.fromARGB(255, 207, 205, 205),
              margin: const EdgeInsets.all(0),
              child: const Row(
                children: [
                  Expanded(
                    //width: 50,
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                      child: Text('STT'),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                      child: Text('Khu vực'),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 15, 5, 15),
                      child: Text('Tên bàn'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scrollable rows
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: filteredTables.asMap().entries.map((entry) {
                  int index = entry.key;
                  Tables table = entry.value;
                  return Column(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        elevation: 3,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _openEditTableDialog(context, table),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('${index + 1}'),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(_getAreaNameById(table.id_area)),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(table.name),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditTableDialog(BuildContext context, Tables table) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTablePage(
          table: table,
          onUpdateTable: _updateTableInList,
          onDeleteTable: _deleteTableFromList, // Pass the callback
        );
      },
    );
  }

  void _openEditAreaDialog(BuildContext context, Area area) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditAreaPage(
          area: area,
          onUpdateArea: _updateAreaInList,
          onDeleteArea: _deleteAreaFromList, // Pass the callback
        );
      },
    );
  }
}
