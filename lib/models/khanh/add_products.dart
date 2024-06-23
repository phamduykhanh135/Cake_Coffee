import 'dart:typed_data'; // Thư viện để làm việc với dữ liệu dạng byte (Uint8List)
import 'dart:convert';
import 'package:cake_coffee/models/khanh/category_product.dart'; // Model danh mục sản phẩm// Model sản phẩm
import 'package:cake_coffee/presents/khanh/add_category_product.dart';
import 'package:flutter/material.dart'; // Thư viện Flutter để xây dựng giao diện người dùng
import 'package:cloud_firestore/cloud_firestore.dart'; // Thư viện Firestore để làm việc với cơ sở dữ liệu đám mây
import 'package:image_picker/image_picker.dart'; // Thư viện để chọn hình ảnh từ thư viện hoặc camera

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();

  static Future<void> openAddProductDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm sản phẩm'),
          content: const AddProductPage(),
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
  String? _id_unit_products;
  final List<String> _unit_product = [
    'Ly',
    'Cái',
  ];
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

    // In ra số lượng và tên các danh mục để kiểm tra
    print('Categories fetched: ${categories.length}');
    for (var category in categories) {
      print('Category: ${category.name}');
    }
  }

  Future<void> _addProduct() async {
    String name = _nameController.text.trim();
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (_imageBytes != null) {
      try {
        // Encode the image bytes to Base64 string
        String imageString = base64Encode(_imageBytes!);

        // Save product information to Firestore Database
        final productRef =
            FirebaseFirestore.instance.collection('products').doc();
        await productRef.set({
          'id': productRef.id,
          'id_category_product': _selectedCategoryId,
          'name': name,
          'price': price,
          'id_unit_product': _select_unit_product,
          'image': imageString, // Save as Base64 string
          'createTime': DateTime.now(),
          'updateTime': null,
          'deleteTime': null,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
          ),
        );

        // Clear text fields and reset state
        _nameController.clear();
        _priceController.clear();
        setState(() {
          _selectedCategoryId = '';
          _select_unit_product = '';
          _imageBytes = null;
        });
      } catch (e) {
        // Show error message if there's an error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding product: $e'),
          ),
        );
      }
    } else {
      // Show message if no image is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image.'),
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
