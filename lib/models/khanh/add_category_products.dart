// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'category_product.dart'; // Đường dẫn tới lớp Category

// class AddCategoryPage extends StatefulWidget {
//   const AddCategoryPage({super.key});

//   @override
//   _AddCategoryPageState createState() => _AddCategoryPageState();

//   static Future<void> openAddCategoryDialog(BuildContext context) async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Thêm danh mục sản phẩm'),
//           content: const AddCategoryPage(),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Hủy'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class _AddCategoryPageState extends State<AddCategoryPage> {
//   final TextEditingController _nameController = TextEditingController();

//   void _addCategory() {
//     String name = _nameController.text.trim();
//     if (name.isNotEmpty) {
//       Category newCategory = Category(
//         id: FirebaseFirestore.instance.collection('categories').doc().id,
//         name: name,
//         createTime: DateTime.now(),
//         updateTime: DateTime.now(),
//         deleteTime: DateTime.now(),
//       );

//       FirebaseFirestore.instance
//           .collection('categories')
//           .doc(newCategory.id)
//           .set(newCategory.toMap())
//           .then((_) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Đã thêm danh mục sản phẩm thành công!'),
//           ),
//         );
//         _nameController.clear();
//         Navigator.of(context).pop(); // Đóng dialog sau khi thêm danh mục
//       }).catchError((error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Lỗi: $error'),
//           ),
//         );
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Vui lòng nhập tên danh mục sản phẩm.'),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         TextField(
//           controller: _nameController,
//           decoration: const InputDecoration(
//             labelText: 'Tên danh mục',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         const SizedBox(height: 16.0),
//         ElevatedButton(
//           onPressed: _addCategory,
//           child: const Text('Thêm danh mục'),
//         ),
//       ],
//     );
//   }
// }
