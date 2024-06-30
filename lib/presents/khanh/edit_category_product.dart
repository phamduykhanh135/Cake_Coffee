import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_coffee/models/khanh/category_product.dart';

class EditCategory extends StatefulWidget {
  final Category category;
  final Function(Category) onUpdateCategory;
  final Function(String) onDeleteCategory;

  const EditCategory({
    super.key,
    required this.category,
    required this.onUpdateCategory,
    required this.onDeleteCategory,
  });

  static Future<void> openEditCategoryDialog(
    BuildContext context,
    Category category,
    Function(Category) onUpdateCategory,
    Function(String) onDeleteCategory,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCategory(
          category: category,
          onUpdateCategory: onUpdateCategory,
          onDeleteCategory: onDeleteCategory,
        );
      },
    );
  }

  @override
  _EditCategoryPageState createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategory> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  bool _isCategoryInUse = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.category.name);
    _checkCategoryInUse(widget.category.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkCategoryInUse(String categoryId) async {
    QuerySnapshot productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('id_category_product', isEqualTo: categoryId)
        .get();

    setState(() {
      _isCategoryInUse = productSnapshot.docs.isNotEmpty;
    });
  }

  void _editCategoryProduct(String categoryId) async {
    setState(() {
      _isEditing = true;
    });

    String name = _nameController.text.trim();

    //bool isCategoryInUse = await _checkCategoryInUse(categoryId);

    if (_isCategoryInUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Không thể sửa danh mục vì có sản phẩm đang sử dụng danh mục này.'),
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
          .collection('categories')
          .doc(categoryId)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công!'),
        ),
      );

      setState(() {
        _isEditing = false;
        widget.category.name = name;
      });

      widget.onUpdateCategory(widget.category);

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

  void _deleteCategoryProduct(String categoryId) async {
    // bool isCategoryInUse = await _checkCategoryInUse(categoryId);

    if (_isCategoryInUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Không thể xóa danh mục vì có sản phẩm đang sử dụng danh mục này.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .delete();

      widget.onDeleteCategory(categoryId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa danh mục thành công!'),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xóa danh mục thất bại: $error'),
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
                  content: const Text(
                      'Đang cập nhật danh mục sản phẩm, vui lòng đợi...'),
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
          title: const Text('Cập nhật danh mục'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  enabled: !_isCategoryInUse && !_isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Tên danh mục ',
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
              onPressed: _isEditing
                  ? null
                  : () => _editCategoryProduct(widget.category.id),
              child: _isEditing
                  ? const CircularProgressIndicator()
                  : const Text('Lưu'),
            ),
            ElevatedButton(
              onPressed: _isEditing
                  ? null
                  : () => _deleteCategoryProduct(widget.category.id),
              style: ElevatedButton.styleFrom(
                iconColor: Colors.red,
              ),
              child: const Text('Xóa'),
            ),
          ],
        ));
  }
}
