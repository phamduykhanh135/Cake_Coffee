import 'package:cake_coffee/models/khanh/category_product.dart';
import 'package:cake_coffee/models/khanh/products.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class AddProductPage extends StatefulWidget {
  final Function(Product) onAddProduct;
  final VoidCallback onCancel;

  const AddProductPage(
      {super.key, required this.onAddProduct, required this.onCancel});

  @override
  _AddProductPageState createState() => _AddProductPageState();

  static Future<void> openAddProductDialog(
    BuildContext context,
    Function(Product) onAddProduct,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddProductPage(
          onAddProduct: onAddProduct,
          onCancel: () {
            Navigator.of(context).pop();
          },
          // ),
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
  Uint8List? _imageBytes;
  List<Category> categories = [];
  final List<String> _unit_product = ['Ly', 'Cái'];
  bool _isLoading = false;
  String _formattedPrice = '';
  @override
  void initState() {
    super.initState();
    loadCategories();
    _priceController.addListener(_updateFormattedPrice);
  }

  void _updateFormattedPrice() {
    setState(() {
      double price = double.tryParse(_priceController.text) ?? 0.0;
      _formattedPrice = FormartPrice(price: price);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void loadCategories() async {
    List<Category> fetchedCategories = await fetchCategoriesFromFirestore();
    setState(() {
      categories = fetchedCategories;
    });
  }

  Future<String> uploadImageToStorage(Uint8List imageBytes) async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child(
          'product_images/${DateTime.now().millisecondsSinceEpoch}.jpeg');
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
      UploadTask uploadTask = storageRef.putData(imageBytes, metadata);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  void _addProduct() async {
    if (_isLoading || !mounted) return;
    String name = _nameController.text.trim();
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    if (_imageBytes != null &&
        name.isNotEmpty &&
        price > 0 &&
        _selectedCategoryId.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      QuerySnapshot existingTableSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: name)
          .get();
      if (existingTableSnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('sản phẩm đã tồn tại, vui lòng chọn sản phẩm khác.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (price.toString().length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giá sản phẩm tối đa là 5 số (ví dụ:500!.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (name.length > 50) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chiều dài tên sản phẩm tối đa là 50 ký tự!.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      try {
        String imageURL = await uploadImageToStorage(_imageBytes!);

        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('products').add({
          'name': name,
          'price': price,
          'id_category_product': _selectedCategoryId,
          'id_unit_product': _select_unit_product,
          'image': imageURL,
          'create_time': DateTime.now(),
          'update_time': null,
          'delete_time': null,
        });

        Product newProduct = Product(
          id: docRef.id,
          name: name,
          price: price,
          id_category_product: _selectedCategoryId,
          id_unit_product: _select_unit_product,
          image: imageURL,
          create_time: DateTime.now(),
          update_time: null,
          delete_time: null,
        );

        widget.onAddProduct(newProduct);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm sản phẩm thành công!'),
          ),
        );

        _nameController.clear();
        _priceController.clear();
        setState(() {
          _imageBytes = null;
          _isLoading = false;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm sản phẩm thất bại: $error'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin sản phẩm.'),
        ),
      );
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
                content: const Text('Đang thêm sản phẩm, vui lòng đợi...'),
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
        title: const Text('Thêm sản phẩm'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Column(
                    children: [],
                  )
                ],
              ),
              const Row(
                children: [
                  Column(
                    children: [],
                  )
                ],
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
                onChanged: _isLoading
                    ? null
                    : (String? newValue) {
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
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Chọn đơn vị',
                  border: OutlineInputBorder(),
                ),
                value:
                    _select_unit_product.isEmpty ? null : _select_unit_product,
                items: _unit_product.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _select_unit_product = newValue ?? '';
                        });
                      },
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageBytes == null
                      ? const Center(child: Text('Chọn ảnh'))
                      : Image.memory(_imageBytes!, fit: BoxFit.cover),
                ),
              ),
              // const SizedBox(height: 16.0),
              // _imageBytes == null
              //     ? ElevatedButton(
              //         onPressed: _isLoading ? null : _pickImage,
              //         child: const Text('Chọn ảnh'),
              //       )
              //     : Image.memory(
              //         _imageBytes!,
              //         height: 150,
              //         fit: BoxFit.cover,
              //       ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _addProduct,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Thêm sản phẩm'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isLoading ? null : widget.onCancel,
                child: const Text('Hủy'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String FormartPrice({required double price}) {
    String formattedAmount =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
    return formattedAmount;
  }
}
