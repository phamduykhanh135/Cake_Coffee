import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_coffee/models/khanh/category_product.dart';
import 'package:cake_coffee/models/khanh/products.dart';

class EditProductsPage extends StatefulWidget {
  final Product product;
  final Function(Product) onUpdateProduct;
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
    Function(String) onDeleteProduct,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditProductsPage(
          product: product,
          onUpdateProduct: onUpdateProduct,
          onDeleteProduct: onDeleteProduct,
        );
      },
    );
  }

  @override
  _EditProductsPageState createState() => _EditProductsPageState();
}

class _EditProductsPageState extends State<EditProductsPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  String _selectedCategoryId = '';
  String _selectedUnit = '';
  Uint8List? _imageBytes;
  bool _isEditing = false;
  List<Category> categories = [];
  final List<String> _unitProduct = ['Ly', 'Cái'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _selectedCategoryId = widget.product.id_category_product ?? '';
    _selectedUnit = widget.product.id_unit_product ?? '';
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
      print('Tải danh mục thất bại: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      List<int> imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = Uint8List.fromList(imageBytes);
      });
    }
  }

  Future<String> _uploadImageToStorage(Uint8List imageBytes) async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child(
          'product_images/${DateTime.now().millisecondsSinceEpoch}.jpeg');

      UploadTask uploadTask = storageRef.putData(imageBytes);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Tải hình ảnh thất bại: $e');
    }
  }

  void _editProduct(String productId) async {
    setState(() {
      _isEditing = true;
    });

    String name = _nameController.text.trim();
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    try {
      Map<String, dynamic> updatedData = {
        'name': name,
        'price': price,
        'id_category_product': _selectedCategoryId,
        'id_unit_product': _selectedUnit,
        'update_time': DateTime.now()
      };

      if (_imageBytes != null) {
        String imageURL = await _uploadImageToStorage(_imageBytes!);
        updatedData['image'] = imageURL;
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thàn công!'),
        ),
      );

      setState(() {
        _isEditing = false;
        widget.product.name = name;
        widget.product.price = price;
        widget.product.id_category_product = _selectedCategoryId;
        widget.product.id_unit_product = _selectedUnit;
        if (_imageBytes != null) {
          widget.product.image = updatedData['image'];
        }
      });

      widget.onUpdateProduct(widget.product);

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

  void _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();

      widget.onDeleteProduct(productId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully!'),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: $error'),
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
                  content:
                      const Text('Đang cập nhật sản phẩm, vui lòng đợi...'),
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
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  onChanged: _isEditing
                      ? null
                      : (String? newValue) {
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
                  enabled: !_isEditing, //#true là false
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
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
                  enabled: !_isEditing,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  onChanged: _isEditing
                      ? null
                      : (String? newValue) {
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
                    labelText: 'Đơn vị',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                _imageBytes == null
                    ? ElevatedButton(
                        onPressed: _isEditing ? null : _pickImage,
                        child: const Text('Chọn hình ảnh'),
                      )
                    : Image.memory(
                        _imageBytes!,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
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
              onPressed:
                  _isEditing ? null : () => _editProduct(widget.product.id),
              child: _isEditing
                  ? const CircularProgressIndicator()
                  : const Text('Lưu'),
            ),
            ElevatedButton(
              onPressed:
                  _isEditing ? null : () => _deleteProduct(widget.product.id),
              style: ElevatedButton.styleFrom(
                iconColor: Colors.red,
              ),
              child: const Text('Xóa'),
            ),
          ],
        ));
  }
}
