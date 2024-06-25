// import 'dart:typed_data'; // Thư viện để làm việc với dữ liệu dạng byte (Uint8List)
// import 'dart:convert';
// import 'package:cake_coffee/models/khanh/category_product.dart'; // Model danh mục sản phẩm// Model sản phẩm
// import 'package:cake_coffee/models/khanh/products.dart';
// import 'package:cake_coffee/presents/khanh/add_category_product.dart';
// import 'package:flutter/material.dart'; // Thư viện Flutter để xây dựng giao diện người dùng
// import 'package:cloud_firestore/cloud_firestore.dart'; // Thư viện Firestore để làm việc với cơ sở dữ liệu đám mây
// import 'package:image_picker/image_picker.dart'; // Thư viện để chọn hình ảnh từ thư viện hoặc camera

// class AddProductPage extends StatefulWidget {
//   final Function(Product) onAddProduct; // Callback để cập nhật bảng DataTable

//   const AddProductPage({super.key, required this.onAddProduct});

//   @override
//   _AddProductPageState createState() => _AddProductPageState();

//   static Future<void> openAddProductDialog(
//       BuildContext context, Function(Product) onAddProduct) async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Thêm sản phẩm'),
//           content: AddProductPage(
//             onAddProduct: onAddProduct,
//           ),
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

// class _AddProductPageState extends State<AddProductPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   String _select_unit_product = '';

//   String _selectedCategoryId = '';
//   Uint8List? _imageBytes; // Dữ liệu byte của hình ảnh
//   List<Category> categories =
//       []; // Danh sách các danh mục sản phẩm từ Firestore
//   final List<String> _unit_product = [
//     'Ly',
//     'Cái',
//   ];
//   @override
//   void initState() {
//     super.initState();
//     loadCategories();
//   }

//   void loadCategories() async {
//     List<Category> fetchedCategories = await fetchCategoriesFromFirestore();
//     setState(() {
//       categories = fetchedCategories;
//     });

//     // In ra số lượng và tên các danh mục để kiểm tra
//     print('Categories fetched: ${categories.length}');
//     for (var category in categories) {
//       print('Category: ${category.name}');
//     }
//   }

//   void _addProduct() async {
//     String name = _nameController.text.trim();
//     double price = double.tryParse(_priceController.text.trim()) ?? 0.0;

//     if (_imageBytes != null) {
//       String imageString = base64Encode(_imageBytes!);

//       try {
//         DocumentReference docRef =
//             await FirebaseFirestore.instance.collection('products').add({
//           'name': name,
//           'price': price,
//           'id_category_product': _selectedCategoryId,
//           'id_unit_product': _select_unit_product,
//           'image': imageString,
//           'createTime': DateTime.now(),
//           'updateTime': null,
//           'deleteTime': null,
//         });

//         Product newProduct = Product(
//             id: docRef.id,
//             name: name,
//             price: price,
//             id_category_product: _selectedCategoryId,
//             id_unit_product: _select_unit_product,
//             image: imageString,
//             createTime: DateTime.now(),
//             updateTime: null,
//             deleteTime: null);

//         // Call the callback function to notify the parent widget
//         widget.onAddProduct(newProduct);

//         // Show success message and reset form
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Product added successfully!'),
//           ),
//         );

//         _nameController.clear();
//         _priceController.clear();
//         setState(() {
//           _imageBytes = null;
//         });
//       } catch (error) {
//         // Show error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('aaaFailed to add product: $error'),
//           ),
//         );
//       }
//     } else {
//       // Show message to pick an image
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please pick an image for the product.'),
//         ),
//       );
//     }
//   }

//   Future<void> _pickImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       // Đọc dữ liệu byte từ hình ảnh đã chọn
//       List<int> imageBytes = await pickedFile.readAsBytes();
//       setState(() {
//         _imageBytes = Uint8List.fromList(imageBytes);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
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
//                 labelText: 'Tên sản phẩm',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: _priceController,
//               decoration: const InputDecoration(
//                 labelText: 'Giá',
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
//             const SizedBox(height: 16.0),
//             _imageBytes == null
//                 ? ElevatedButton(
//                     onPressed: _pickImage,
//                     child: const Text('Chọn ảnh'),
//                   )
//                 : Image.memory(
//                     _imageBytes!,
//                     height: 150,
//                     fit: BoxFit.cover,
//                   ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: _addProduct,
//               child: const Text('Thêm sản phẩm'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:typed_data'; // Thư viện để làm việc với dữ liệu dạng byte (Uint8List)
import 'dart:convert';
import 'package:cake_coffee/models/khanh/category_product.dart'; // Model danh mục sản phẩm
import 'package:cake_coffee/models/khanh/products.dart';
import 'package:cake_coffee/presents/khanh/add_category_product.dart';
import 'package:flutter/material.dart'; // Thư viện Flutter để xây dựng giao diện người dùng
import 'package:cloud_firestore/cloud_firestore.dart'; // Thư viện Firestore để làm việc với cơ sở dữ liệu đám mây
import 'package:image_picker/image_picker.dart'; // Thư viện để chọn hình ảnh từ thư viện hoặc camera
import 'package:firebase_storage/firebase_storage.dart'; // Thư viện để làm việc với Firebase Storage

class AddProductPage extends StatefulWidget {
  final Function(Product) onAddProduct; // Callback để cập nhật bảng DataTable

  const AddProductPage({super.key, required this.onAddProduct});

  @override
  _AddProductPageState createState() => _AddProductPageState();

  static Future<void> openAddProductDialog(
      BuildContext context, Function(Product) onAddProduct) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm sản phẩm'),
          content: AddProductPage(
            onAddProduct: onAddProduct,
          ),
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

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _select_unit_product = '';

  String _selectedCategoryId = '';
  Uint8List? _imageBytes; // Dữ liệu byte của hình ảnh
  List<Category> categories =
      []; // Danh sách các danh mục sản phẩm từ Firestore
  final List<String> _unit_product = ['Ly', 'Cái'];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    List<Category> fetchedCategories = await fetchCategoriesFromFirestore();
    setState(() {
      categories = fetchedCategories;
    });
  }

  // Future<String> uploadImageToStorage(Uint8List imageBytes) async {
  //   try {
  //     // Tạo tham chiếu đến Firebase Storage
  //     Reference storageRef = FirebaseStorage.instance.ref().child(
  //         'product_images/${DateTime.now().millisecondsSinceEpoch}.jpeg');

  //     // Tải lên hình ảnh lên Firebase Storage
  //     UploadTask uploadTask = storageRef.putData(imageBytes);
  //     TaskSnapshot taskSnapshot = await uploadTask;

  //     // Lấy URL của hình ảnh đã tải lên
  //     String downloadURL = await taskSnapshot.ref.getDownloadURL();
  //     return downloadURL;
  //   } catch (e) {
  //     throw Exception('Failed to upload image: $e');
  //   }
  // }
  Future<String> uploadImageToStorage(Uint8List imageBytes) async {
    try {
      // Tạo tham chiếu đến Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child(
          'product_images/${DateTime.now().millisecondsSinceEpoch}.jpeg');

      // Đặt metadata cho hình ảnh
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

      // Tải lên hình ảnh lên Firebase Storage với metadata
      UploadTask uploadTask = storageRef.putData(imageBytes, metadata);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Lấy URL của hình ảnh đã tải lên
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  void _addProduct() async {
    String name = _nameController.text.trim();
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (_imageBytes != null) {
      try {
        // Tải lên hình ảnh lên Firebase Storage và lấy URL
        String imageURL = await uploadImageToStorage(_imageBytes!);

        // Lưu trữ thông tin sản phẩm vào Firestore
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('products').add({
          'name': name,
          'price': price,
          'id_category_product': _selectedCategoryId,
          'id_unit_product': _select_unit_product,
          'image': imageURL,
          'createTime': DateTime.now(),
          'updateTime': null,
          'deleteTime': null,
        });

        Product newProduct = Product(
            id: docRef.id,
            name: name,
            price: price,
            id_category_product: _selectedCategoryId,
            id_unit_product: _select_unit_product,
            image: imageURL,
            createTime: DateTime.now(),
            updateTime: null,
            deleteTime: null);

        // Gọi callback để thông báo cho widget cha
        widget.onAddProduct(newProduct);

        // Hiển thị thông báo thành công và đặt lại form
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
          ),
        );

        _nameController.clear();
        _priceController.clear();
        setState(() {
          _imageBytes = null;
        });
      } catch (error) {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product: $error'),
          ),
        );
      }
    } else {
      // Hiển thị thông báo yêu cầu chọn ảnh
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick an image for the product.'),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Đọc dữ liệu byte từ hình ảnh đã chọn
      List<int> imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = Uint8List.fromList(imageBytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategoryId = newValue ?? '';
                });
              },
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên sản phẩm',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Giá',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Chọn đơn vị',
                border: OutlineInputBorder(),
              ),
              value: _select_unit_product.isEmpty ? null : _select_unit_product,
              items: _unit_product.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _select_unit_product = newValue ?? '';
                });
              },
            ),
            const SizedBox(height: 16.0),
            _imageBytes == null
                ? ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Chọn ảnh'),
                  )
                : Image.memory(
                    _imageBytes!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Thêm sản phẩm'),
            ),
          ],
        ),
      ),
    );
  }
}
