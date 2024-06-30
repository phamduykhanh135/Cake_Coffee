import 'package:cake_coffee/models/khanh/area.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAreaPage extends StatefulWidget {
  final Area area;
  final Function(Area) onUpdateArea;
  final Function(String) onDeleteArea;

  const EditAreaPage({
    super.key,
    required this.area,
    required this.onUpdateArea,
    required this.onDeleteArea,
  });

  static Future<void> openEditAreaDialog(
    BuildContext context,
    Area area,
    Function(Area) onUpdateArea,
    Function(String) onDeleteArea,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditAreaPage(
          area: area,
          onUpdateArea: onUpdateArea,
          onDeleteArea: onDeleteArea,
        );
      },
    );
  }

  @override
  _EditAreaPage createState() => _EditAreaPage();
}

class _EditAreaPage extends State<EditAreaPage> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  bool _isAreaInUse = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.area.name);
    _checkAreaInUse(widget.area.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkAreaInUse(String areaId) async {
    QuerySnapshot tableSnapshot = await FirebaseFirestore.instance
        .collection('tables')
        .where('id_area', isEqualTo: areaId)
        .get();

    setState(() {
      _isAreaInUse = tableSnapshot.docs.isNotEmpty;
    });
  }

  void _editArea(String areaId) async {
    setState(() {
      _isEditing = true;
    });

    String name = _nameController.text.trim();

    if (_isAreaInUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Không thể sửa khu vực vì có bàn đang sử dụng khu vực này.'),
        ),
      );
      setState(() {
        _isEditing = false;
      });
      return;
    }

    try {
      Map<String, dynamic> updatedData = {
        'name': name,
      };

      await FirebaseFirestore.instance
          .collection('areas')
          .doc(areaId)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công!'),
        ),
      );

      setState(() {
        _isEditing = false;
        widget.area.name = name;
      });

      widget.onUpdateArea(widget.area);

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật thất bại: $error'),
        ),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _deleteArea(String areaId) async {
    if (_isAreaInUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Không thể xóa khu vực vì có bàn đang sử dụng khu vực này.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('areas').doc(areaId).delete();

      widget.onDeleteArea(areaId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa khu vực thành công!'),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xóa khu vực thất bại: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_isEditing) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thông báo'),
                  content: const Text('Đang cập nhật khu vực, vui lòng đợi...'),
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
            return false; // Prevent back navigation if loading
          }
          return true;
        },
        child: AlertDialog(
          title: const Text('Cập nhật khu vực'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  enabled: !_isAreaInUse && !_isEditing, //#true là false
                  decoration: const InputDecoration(
                    labelText: 'Tên khu vực ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _isEditing
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: const Text('Thoát'),
            ),
            ElevatedButton(
              onPressed: _isEditing ? null : () => _editArea(widget.area.id),
              child: _isEditing
                  ? const CircularProgressIndicator()
                  : const Text('Lưu'),
            ),
            ElevatedButton(
              onPressed: _isEditing ? null : () => _deleteArea(widget.area.id),
              style: ElevatedButton.styleFrom(
                iconColor: Colors.red,
              ),
              child: const Text('Xóa'),
            ),
          ],
        ));
  }
}
