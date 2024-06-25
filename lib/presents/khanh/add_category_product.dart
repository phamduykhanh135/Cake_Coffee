import 'package:cake_coffee/models/khanh/category_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Add_Category_Product extends StatefulWidget {
  const Add_Category_Product({super.key});

  @override
  State<Add_Category_Product> createState() => _Add_Category_ProductState();
  static Future<void> openAddProductDialog(
    BuildContext context,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm sản phẩm'),
          content: const Add_Category_Product(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }
}

class _Add_Category_ProductState extends State<Add_Category_Product> {
  final TextEditingController _nameController = TextEditingController();
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên sản phẩm',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addCategory,
              child: const Text('Thêm sản phẩm'),
            ),
          ],
        ),
      ),
    );
  }

  // Future<List<Category>> fetchCategoriesFromFirestore() async {
  //   try {
  //     QuerySnapshot querySnapshot =
  //         await FirebaseFirestore.instance.collection('categories').get();
  //     return querySnapshot.docs
  //         .map((doc) => Category.fromFirestore(doc))
  //         .toList();
  //   } catch (e) {
  //     print('Error fetching categories: $e');
  //     return [];
  //   }
  // }

  Future<void> _addCategory() async {
    String name = _nameController.text.trim();
    if (name.isNotEmpty) {
      Category newCategory = Category(
        id: FirebaseFirestore.instance.collection('categories').doc().id,
        name: name,
        createTime: DateTime.now(),
        updateTime: null,
        deleteTime: null,
      );

      try {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(newCategory.id)
            .set(newCategory.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm danh mục sản phẩm thành công!'),
          ),
        );
        Navigator.of(context)
            .pop(); // Close the dialog after adding the category
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $error'),
          ),
        );
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
