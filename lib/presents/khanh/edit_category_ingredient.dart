import 'package:cake_coffee/models/khanh/category_ingredient.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCategory_Ingredient extends StatefulWidget {
  final Category_Ingredient category_ingredient;
  final Function(Category_Ingredient) onUpdateCategory_Ingredient;
  final Function(String) onDeleteCategory_Ingredient;

  const EditCategory_Ingredient({
    super.key,
    required this.category_ingredient,
    required this.onUpdateCategory_Ingredient,
    required this.onDeleteCategory_Ingredient,
  });

  static Future<void> openEditCategoryDialog(
    BuildContext context,
    Category_Ingredient categoryIngredient,
    Function(Category_Ingredient) onupdatecategoryIngredient,
    Function(String) ondeletecategoryIngredient,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCategory_Ingredient(
          category_ingredient: categoryIngredient,
          onUpdateCategory_Ingredient: onupdatecategoryIngredient,
          onDeleteCategory_Ingredient: ondeletecategoryIngredient,
        );
      },
    );
  }

  @override
  _EditCategory_IngredientState createState() =>
      _EditCategory_IngredientState();
}

class _EditCategory_IngredientState extends State<EditCategory_Ingredient> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  bool _isCategory_IngredientInUse = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.category_ingredient.name);
    _checkCategory_IngregientInUse(widget.category_ingredient.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkCategory_IngregientInUse(
      String categoryIngredientid) async {
    QuerySnapshot ingredientSnapshot = await FirebaseFirestore.instance
        .collection('ingredients')
        .where('id_category_ingredient', isEqualTo: categoryIngredientid)
        .get();

    setState(() {
      _isCategory_IngredientInUse = ingredientSnapshot.docs.isNotEmpty;
    });
  }

  void _editCategoryInredient(String categoryIngredientid) async {
    setState(() {
      _isEditing = true;
    });

    String name = _nameController.text.trim();
    try {
      // Kiểm tra xem tên sản phẩm mới đã tồn tại chưa
      if (name != widget.category_ingredient.name) {
        QuerySnapshot existingProductSnapshot = await FirebaseFirestore.instance
            .collection('category_ingredients')
            .where('name', isEqualTo: name)
            .get();

        if (existingProductSnapshot.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tên danh mục đã tồn tại, vui lòng chọn tên khác.'),
            ),
          );
          setState(() {
            _isEditing = false;
          });
          return;
        }
      }
      if (name.length > 15) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chiều dài tối đa là 15 ký tự!.'),
          ),
        );
        setState(() {
          _isEditing = false;
        });
        return;
      }
      if (_isCategory_IngredientInUse) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Không thể sửa danh mục vì có nguyên liệu đang sử dụng danh mục này.'),
          ),
        );
        setState(() {
          _isEditing = false;
        });
        return;
      }

      Map<String, dynamic> updatedData = {
        'name': name,
      };

      await FirebaseFirestore.instance
          .collection('category_ingredients')
          .doc(categoryIngredientid)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công!'),
        ),
      );

      setState(() {
        _isEditing = false;
        widget.category_ingredient.name = name;
      });

      widget.onUpdateCategory_Ingredient(widget.category_ingredient);

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thất bại!'),
          //'Cập nhật thất bại: $error'
        ),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _deleteCategoryInredient(String categoryIngredientid) async {
    if (_isCategory_IngredientInUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Không thể xóa danh mục vì có nguyên liệu đang sử dụng danh mục này.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('category_ingredients')
          .doc(categoryIngredientid)
          .delete();

      widget.onDeleteCategory_Ingredient(categoryIngredientid);

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
                      'Đang cập nhật danh mục nguyên liệu, vui lòng đợi...'),
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
          title: const Text('Cập nhật danh mục nguyên liệu'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  enabled: !_isCategory_IngredientInUse &&
                      !_isEditing, //#true là false
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
                  : () => _editCategoryInredient(widget.category_ingredient.id),
              child: _isEditing
                  ? const CircularProgressIndicator()
                  : const Text('Lưu'),
            ),
            ElevatedButton(
              onPressed: _isEditing
                  ? null
                  : () =>
                      _deleteCategoryInredient(widget.category_ingredient.id),
              style: ElevatedButton.styleFrom(
                iconColor: Colors.red,
              ),
              child: const Text('Xóa'),
            ),
          ],
        ));
  }
}
