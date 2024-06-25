// import 'package:cake_coffee/models/khanh/category_product.dart';
// import 'package:cake_coffee/models/khanh/products.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class EditProducts extends StatefulWidget {
//   final Product product;

//   const EditProducts({super.key, required this.product});

//   @override
//   _EditProductsState createState() => _EditProductsState();
// }

// class _EditProductsState extends State<EditProducts> {
//   late TextEditingController _nameController;
//   late TextEditingController _priceController;
//   String _selectedCategoryId = '';
//   String _select_unit_product = '';
//   List<Category> categories = [];
//   final List<String> _unit_product = [
//     'Ly',
//     'Cái',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.product.name);
//     _priceController =
//         TextEditingController(text: widget.product.price.toString());
//     _selectedCategoryId = widget.product.id_category_product ?? '';
//     _select_unit_product = widget.product.id_unit_product ?? '';
//     loadCategories();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }

//   void loadCategories() async {
//     try {
//       List<Category> fetchedCategories = await fetchCategoriesFromFirestore();
//       setState(() {
//         categories = fetchedCategories;
//       });
//     } catch (e) {
//       print('Error loading categories: $e');
//       // Handle error loading categories
//     }
//   }

//   Future<List<Category>> fetchCategoriesFromFirestore() async {
//     QuerySnapshot querySnapshot =
//         await FirebaseFirestore.instance.collection('categories').get();
//     List<Category> categories =
//         querySnapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
//     return categories;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Edit Product'),
//       content: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             DropdownButtonFormField<String>(
//               value: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedCategoryId = newValue ?? '';
//                 });
//               },
//               items: categories.map((category) {
//                 return DropdownMenuItem(
//                   value: category.id,
//                   child: Text(category.name),
//                 );
//               }).toList(),
//               decoration: const InputDecoration(
//                 labelText: 'Danh mục',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Product Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: _priceController,
//               decoration: const InputDecoration(
//                 labelText: 'Price',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 16.0),
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(
//                 labelText: 'Chọn đơn vị',
//                 border: OutlineInputBorder(),
//               ),
//               value: _select_unit_product.isEmpty ? null : _select_unit_product,
//               items: _unit_product.map((String unit) {
//                 return DropdownMenuItem<String>(
//                   value: unit,
//                   child: Text(unit),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _select_unit_product = newValue ?? '';
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             _editProduct(widget.product.id);
//             Navigator.of(context).pop();
//           },
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }

//   void _editProduct(String productId) async {
//     String name = _nameController.text.trim();
//     double price = double.tryParse(_priceController.text.trim()) ?? 0.0;

//     try {
//       await FirebaseFirestore.instance
//           .collection('products')
//           .doc(productId)
//           .update({
//         'name': name,
//         'price': price,
//         'id_category_product': _selectedCategoryId,
//         'id_unit_product': _select_unit_product,
//       });

//       // Cập nhật thành công, hiển thị thông báo
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Product updated successfully!'),
//         ),
//       );

//       // Cập nhật trạng thái UI nếu cần thiết
//       setState(() {
//         widget.product.name = name;
//         widget.product.price = price;
//         widget.product.id_category_product = _selectedCategoryId;
//         widget.product.id_unit_product = _select_unit_product;
//       });
//     } catch (error) {
//       // Xử lý lỗi nếu cập nhật không thành công
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update product: $error'),
//         ),
//       );
//     }
//   }
// }

// import 'package:cake_coffee/models/khanh/category_product.dart';
// import 'package:cake_coffee/models/khanh/products.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class EditProductsPage extends StatefulWidget {
//   final Product product;

//   const EditProductsPage({super.key, required this.product});

//   @override
//   _EditProductsPageState createState() => _EditProductsPageState();  static Future<void> openAddProductDialog(BuildContext context) async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title:  Text('Thêm sản phẩm'),
//           content:  EditProductsPage(product: product,),
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

// class _EditProductsPageState extends State<EditProductsPage> {
//   late TextEditingController _nameController;
//   late TextEditingController _priceController;
//   String _selectedCategoryId = '';
//   String _selectedUnit = '';
//   List<Category> categories = [];
//   final List<String> _unitProduct = [
//     'Ly',
//     'Cái',
//   ]; // Replace with your actual units

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.product.name);
//     _priceController =
//         TextEditingController(text: widget.product.price.toString());
//     _selectedCategoryId = widget.product.id_category_product;
//     _selectedUnit = widget.product.id_unit_product;
//     loadCategories();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }

//   void loadCategories() async {
//     try {
//       List<Category> fetchedCategories = await fetchCategoriesFromFirestore();
//       setState(() {
//         categories = fetchedCategories;
//       });
//     } catch (e) {
//       print('Error loading categories: $e');
//       // Handle error loading categories
//     }
//   }

//   Future<List<Category>> fetchCategoriesFromFirestore() async {
//     QuerySnapshot querySnapshot =
//         await FirebaseFirestore.instance.collection('categories').get();
//     List<Category> categories =
//         querySnapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
//     return categories;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Product'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             DropdownButtonFormField<String>(
//               value: _selectedCategoryId,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedCategoryId = newValue ?? '';
//                 });
//               },
//               items: categories.map((category) {
//                 return DropdownMenuItem<String>(
//                   value: category.id,
//                   child: Text(category.name),
//                 );
//               }).toList(),
//               decoration: const InputDecoration(
//                 labelText: 'Category',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Product Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: _priceController,
//               decoration: const InputDecoration(
//                 labelText: 'Price',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 16.0),
//             DropdownButtonFormField<String>(
//               value: _selectedUnit,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedUnit = newValue ?? '';
//                 });
//               },
//               items: _unitProduct.map((unit) {
//                 return DropdownMenuItem<String>(
//                   value: unit,
//                   child: Text(unit),
//                 );
//               }).toList(),
//               decoration: const InputDecoration(
//                 labelText: 'Unit',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 _editProduct(widget.product.id);
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _editProduct(String productId) async {
//     String name = _nameController.text.trim();
//     double price = double.tryParse(_priceController.text.trim()) ?? 0.0;

//     try {
//       await FirebaseFirestore.instance
//           .collection('products')
//           .doc(productId)
//           .update({
//         'name': name,
//         'price': price,
//         'id_category_product': _selectedCategoryId,
//         'id_unit_product': _selectedUnit,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Product updated successfully!'),
//         ),
//       );

//       setState(() {
//         widget.product.name = name;
//         widget.product.price = price;
//         widget.product.id_category_product = _selectedCategoryId;
//         widget.product.id_unit_product = _selectedUnit;
//       });

//       Navigator.of(context)
//           .pop(); // Close the edit page after successful update
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to update product: $error'),
//         ),
//       );
//     }
//   }
// }
import 'dart:convert';
import 'dart:typed_data';

import 'package:cake_coffee/models/khanh/category_product.dart';
import 'package:cake_coffee/models/khanh/products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductsPage extends StatefulWidget {
  final Product product;
  final Function(Product)
      onUpdateProduct; // Callback để cập nhật bảng DataTable
  final Function(String) onDeleteProduct;

  const EditProductsPage({
    super.key,
    required this.product,
    required this.onUpdateProduct,
    required this.onDeleteProduct,
  });

  static Future<void> openEditProductDialog(
      BuildContext context,
      Product product,
      Function(Product) onUpdateProduct,
      Function(String) onDeleteProduct) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditProductsPage(
            product: product,
            onUpdateProduct: onUpdateProduct,
            onDeleteProduct: onDeleteProduct);
      },
    );
  }

  @override
  _EditProductsPageState createState() => _EditProductsPageState();
}

class _EditProductsPageState extends State<EditProductsPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  // Uint8List? _imageBytes;
  // Uint8List? _currentImageBytes;
  String _selectedCategoryId = '';
  String _selectedUnit = '';
  List<Category> categories = [];
  List<Product> products = [];
  final List<String> _unitProduct = [
    'Ly',
    'Cái',
  ]; // Replace with your actual units

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _selectedCategoryId = widget.product.id_category_product ?? '';
    _selectedUnit = widget.product.id_unit_product ?? '';
    // if (widget.product.image.isNotEmpty) {
    //   _currentImageBytes = base64Decode(widget.product.image);
    // }
    loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void loadCategories() async {
    try {
      List<Category> fetchedCategories = await fetchCategoriesFromFirestore();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print('Error loading categories: $e');
      // Handle error loading categories
    }
  }

  Future<List<Category>> fetchCategoriesFromFirestore() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    List<Category> categories =
        querySnapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
    return categories;
  }

  // Future<void> _pickImage() async {
  //   final pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     List<int> imageBytes = await pickedFile.readAsBytes();
  //     setState(() {
  //       _imageBytes = Uint8List.fromList(imageBytes);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Product'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategoryId = newValue ?? '';
                });
              },
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedUnit = newValue ?? '';
                });
              },
              items: _unitProduct.map((unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Unit',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            //       _currentImageBytes == null && _imageBytes == null
            //           ? ElevatedButton(
            //               onPressed: _pickImage,
            //               child: const Text('Chọn ảnh'),
            //             )
            //           : Column(
            //               children: [
            //                 if (_currentImageBytes != null)
            //                   Image.memory(
            //                     _currentImageBytes!,
            //                     height: 150,
            //                     fit: BoxFit.cover,
            //                   ),
            //                 if (_imageBytes != null)
            //                   Image.memory(
            //                     _imageBytes!,
            //                     height: 150,
            //                     fit: BoxFit.cover,
            //                   ),
            //                 ElevatedButton(
            //                   onPressed: _pickImage,
            //                   child: const Text('Chọn ảnh mới'),
            //                 ),
            //               ],
            //             ),
            //     ],
            //   ),
            // ),
            //     if (_imageBytes == null)
            //       if (_currentImageBytes == null)
            //         ElevatedButton(
            //           onPressed: _pickImage,
            //           child: const Text('Chọn ảnh'),
            //         )
            //       else
            //         Column(
            //           children: [
            //             Image.memory(
            //               _currentImageBytes!,
            //               height: 150,
            //               fit: BoxFit.cover,
            //             ),
            //             ElevatedButton(
            //               onPressed: _pickImage,
            //               child: const Text('Chọn ảnh mới'),
            //             ),
            //           ],
            //         )
            //     else
            //       Column(
            //         children: [
            //           Image.memory(
            //             _imageBytes!,
            //             height: 150,
            //             fit: BoxFit.cover,
            //           ),
            //           ElevatedButton(
            //             onPressed: _pickImage,
            //             child: const Text('Chọn ảnh mới'),
            //           ),
            //         ],
            //       ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _editProduct(widget.product.id);
          },
          child: const Text('Save'),
        ),
        ElevatedButton(
          onPressed: () {
            _deleteProduct(widget.product.id);
          },
          style: ElevatedButton.styleFrom(
            iconColor: Colors.red,
          ),
          child: const Text('Xóa'),
        ),
      ],
    );
  }

  void _editProduct(String productId) async {
    String name = _nameController.text.trim();
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    try {
      Map<String, dynamic> updatedData = {
        'name': name,
        'price': price,
        'idCategoryProduct': _selectedCategoryId,
        'idUnitProduct': _selectedUnit,
      };

      // if (_imageBytes != null) {
      //   updatedData['image'] = base64Encode(_imageBytes!);
      // }
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update(updatedData);
      // await FirebaseFirestore.instance
      //     .collection('products')
      //     .doc(productId)
      //     .update({
      //   'name': name,
      //   'price': price,
      //   'idCategoryProduct': _selectedCategoryId,
      //   'idUnitProduct': _selectedUnit,
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully!'),
        ),
      );

      setState(() {
        widget.product.name = name;
        widget.product.price = price;
        widget.product.id_category_product = _selectedCategoryId;
        widget.product.id_unit_product = _selectedUnit;
        // if (_imageBytes != null) {
        //   widget.product.image = base64Encode(_imageBytes!);
        //   _currentImageBytes = _imageBytes;
        // }
      });

      // Gọi callback để cập nhật bảng DataTable trên OtherPage
      widget.onUpdateProduct(widget.product);

      Navigator.of(context).pop(); // Đóng dialog sau khi cập nhật thành công
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update product: $error'),
        ),
      );
    }
  }

  void _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();

      setState(() {
        products.removeWhere((product) => product.id == productId);
      });
      widget.onUpdateProduct(widget.product);
      widget.onDeleteProduct(productId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully!'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: $error'),
        ),
      );
    }
  }

  // void _deleteProduct(String productId) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('products')
  //         .doc(productId)
  //         .delete();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Product deleted successfully!'),
  //       ),
  //     );

  //     // Notify the parent widget to update the product list
  //     widget.onUpdateProduct(widget.product);
  //     Navigator.of(context).pop(); // Close dialog after successful deletion
  //   } catch (error) {
  //     print('Failed to delete product: $error');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to delete product: $error'),
  //       ),
  //     );
  //   }
  // }
}
