import 'package:cake_coffee/models/khanh/category_ingredient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Add_Category_Ingredient extends StatefulWidget {
  final Function(Category_Ingredient)
      onAddCategory_Ingredient; // Callback để cập nhật bảng DataTable
  final VoidCallback onCancel; // Defi
  const Add_Category_Ingredient(
      {super.key,
      required this.onAddCategory_Ingredient,
      required this.onCancel});

  @override
  State<Add_Category_Ingredient> createState() =>
      _Add_Category_IngredientState();
  static Future<void> openAdd_Category_IngredientDialog(
    BuildContext context,
    Function(Category_Ingredient) onaddcategoryIngredient,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm danh mục nguyên liệu'),
          content: Add_Category_Ingredient(
            onAddCategory_Ingredient: onaddcategoryIngredient,
            onCancel: () {
              Navigator.of(context).pop(); // Implement onCancel action
            },
          ),
        );
      },
    );
  }
}

class _Add_Category_IngredientState extends State<Add_Category_Ingredient> {
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
                  content: const Text(
                      'Đang thêm danh mục nguyên liệu, vui lòng đợi...'),
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
                    labelText: 'Tên danh mục nguyên liệu',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addCategory_Ingredient,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Thêm danh mục nguyên liệu'),
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

  Future<void> _addCategory_Ingredient() async {
    if (_isLoading || !mounted) return;
    String name = _nameController.text.trim();
    if (name.isNotEmpty) {
      Category_Ingredient newCategory = Category_Ingredient(
        id: FirebaseFirestore.instance
            .collection('category_ingredients')
            .doc()
            .id,
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
            .collection('category_ingredients')
            .doc(newCategory.id)
            .set(newCategory.toMap());
        widget.onAddCategory_Ingredient(newCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm danh mục nguyên liệu thành công!'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
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
          content: Text('Vui lòng nhập tên danh mục.'),
        ),
      );
    }
  }
}
