import 'package:cake_coffee/models/khanh/category_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Add_Category_Product extends StatefulWidget {
  final Function(Category) onAddCategory; // Callback để cập nhật bảng DataTable
  final VoidCallback onCancel; // Defi
  const Add_Category_Product(
      {super.key, required this.onAddCategory, required this.onCancel});

  @override
  State<Add_Category_Product> createState() => _Add_Category_ProductState();
  static Future<void> openAdd_Category_ProductDialog(
    BuildContext context,
    Function(Category) onAddCategory,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm danh mục'),
          content: Add_Category_Product(
            onAddCategory: onAddCategory,
            onCancel: () {
              Navigator.of(context).pop(); // Implement onCancel action
            },
          ),
        );
      },
    );
  }
}

class _Add_Category_ProductState extends State<Add_Category_Product> {
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
                  content: const Text('Đang thêm danh mục, vui lòng đợi...'),
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
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16.0),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên danh mục',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addCategory,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Thêm danh mục'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                    onPressed: _isLoading ? null : widget.onCancel,
                    child: const Text('Hủy'))
              ],
            ),
          ),
        ));
  }

  Future<void> _addCategory() async {
    if (_isLoading || !mounted) return;
    String name = _nameController.text.trim();
    if (name.isNotEmpty) {
      QuerySnapshot existingTableSnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('name', isEqualTo: name)
          .get();
      if (existingTableSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Danh mục đã tồn tại, vui lòng chọn danh mục khác.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (name.length > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chiều dài tối đa là 10 ký tự!.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      Category newCategory = Category(
        id: FirebaseFirestore.instance.collection('categories').doc().id,
        name: name,
        createTime: DateTime.now(),
        updateTime: null,
        deleteTime: null,
      );
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(newCategory.id)
            .set(newCategory.toMap());
        widget.onAddCategory(newCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm danh mục sản phẩm thành công!'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        // Navigator.of(context)
        //     .pop(); // Close the dialog after adding the category
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
          content: Text('Vui lòng nhập tên danh mục sản phẩm.'),
        ),
      );
    }
  }
}
