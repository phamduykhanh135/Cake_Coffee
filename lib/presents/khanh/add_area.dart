import 'package:cake_coffee/models/khanh/area.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Add_Area extends StatefulWidget {
  final Function(Area) onAddArea; // Callback để cập nhật bảng DataTable
  final VoidCallback onCancel; // Defi
  const Add_Area({super.key, required this.onAddArea, required this.onCancel});

  @override
  State<Add_Area> createState() => _Add_Area();
  static Future<void> openAdd_Area(
    BuildContext context,
    Function(Area) onAddArea,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm khu vục'),
          content: Add_Area(
            onAddArea: onAddArea,
            onCancel: () {
              Navigator.of(context).pop(); // Implement onCancel action
            },
          ),
        );
      },
    );
  }
}

class _Add_Area extends State<Add_Area> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false; // Biến để xác định trạng thái xử lý
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
                  content: const Text('Đang thêm khụ vực, vui lòng đợi...'),
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
        child: Container(
            child: SingleChildScrollView(
          child: SizedBox(
            width: 300, // Set the width of the dialog
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16.0),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên khu vực',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addArea,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Thêm khu vực'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                    onPressed: _isLoading ? null : widget.onCancel,
                    child: const Text('Hủy'))
              ],
            ),
          ),
        )));
  }

  Future<void> _addArea() async {
    if (_isLoading || !mounted) return;
    String name = _nameController.text.trim();

    if (name.isNotEmpty) {
      QuerySnapshot existingTableSnapshot = await FirebaseFirestore.instance
          .collection('areas')
          .where('name', isEqualTo: name)
          .get();
      if (existingTableSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Khu vực đã tồn tại, vui lòng chọn khuc vực khác.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (name.length > 15) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chiều dài tối đa là 15 ký tự!.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Area newArea = Area(
        id: FirebaseFirestore.instance.collection('areas').doc().id,
        name: name,
        create_time: DateTime.now(),
        update_time: null,
        delete_time: null,
      );
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('areas')
            .doc(newArea.id)
            .set(newArea.toMap());
        widget.onAddArea(newArea);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm khu vực thành công!'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context)
            .pop(); // Close the dialog after adding the category
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $error'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên khu vực.'),
        ),
      );
    }
  }
}
