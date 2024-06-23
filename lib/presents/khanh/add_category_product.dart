import 'package:cake_coffee/models/khanh/category_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<List<Category>> fetchCategoriesFromFirestore() async {
  try {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return querySnapshot.docs
        .map((doc) => Category.fromFirestore(doc))
        .toList();
  } catch (e) {
    print('Error fetching categories: $e');
    return [];
  }
}

Future<void> _addCategory(BuildContext context, String name) async {
  String trimmedName = name.trim();
  if (trimmedName.isNotEmpty) {
    Category newCategory = Category(
      id: FirebaseFirestore.instance.collection('categories').doc().id,
      name: trimmedName,
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
      Navigator.of(context).pop(); // Close the dialog after adding the category
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
