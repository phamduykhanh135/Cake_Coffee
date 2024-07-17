import 'package:cake_coffee/models/khanh/area.dart';
import 'package:cake_coffee/models/khanh/table.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AddTablePage extends StatefulWidget {
  final Function(Tables) onAddTable;
  final VoidCallback onCancel;

  const AddTablePage({
    super.key,
    required this.onAddTable,
    required this.onCancel,
  });

  @override
  _AddTablePage createState() => _AddTablePage();

  static Future<void> openAddTableDialog(
    BuildContext context,
    Function(Tables) onAddTable,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm bàn mới'),
          content: AddTablePage(
            onAddTable: onAddTable,
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}

class _AddTablePage extends State<AddTablePage> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedAreasId = '';
  List<Area> areas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadAreas();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void loadAreas() async {
    List<Area> fetchedAreas = await fetchAreasFromFirestore();
    setState(() {
      areas = fetchedAreas;
    });
  }

  void _addProduct() async {
    if (_isLoading || !mounted) return;
    String name = _nameController.text.trim();
    String status = 'Trống';
    String status2 = '';

    setState(() {
      _isLoading = true;
    });

    if (name.isNotEmpty && _selectedAreasId.isNotEmpty) {
      QuerySnapshot existingTableSnapshot = await FirebaseFirestore.instance
          .collection('tables')
          .where('name', isEqualTo: name)
          .get();

      if (existingTableSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Số bàn đã tồn tại, vui lòng chọn số khác.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (name.length > 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chiều dài tối đa là 3 số!.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      try {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('tables')
            .add({'name': name, 'id_area': _selectedAreasId, 'status': status});

        Tables newProduct = Tables(
          id: docRef.id,
          name: name,
          id_area: _selectedAreasId,
          status: status,
        );

        widget.onAddTable(newProduct);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm bàn thành công!'),
          ),
        );

        _nameController.clear();

        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm bàn thất bại: $error'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin bàn'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Thông báo'),
                content: const Text('Đang thêm bàn, vui lòng đợi...'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Đồng ý'),
                  ),
                ],
              );
            },
          );
          return false;
        }
        return true;
      },
      child: Container(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 300, // Set the width of the dialog
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedAreasId.isEmpty ? null : _selectedAreasId,
                  onChanged: _isLoading
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedAreasId = newValue ?? '';
                          });
                        },
                  items: areas.map((areas) {
                    return DropdownMenuItem(
                      value: areas.id,
                      child: Text(areas.name),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Khu vực',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]')), // Chỉ cho phép nhập số
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Tên bàn (chỉ nhập số)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addProduct,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Thêm bàn'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : widget.onCancel,
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
