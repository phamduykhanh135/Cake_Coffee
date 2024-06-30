import 'dart:typed_data'; // Thư viện để làm việc với dữ liệu dạng byte (Uint8List)
import 'package:cake_coffee/models/khanh/category_ingredient.dart'; // Model danh mục nguyên liệu
import 'package:cake_coffee/models/khanh/ingredient.dart';
import 'package:flutter/material.dart'; // Thư viện Flutter để xây dựng giao diện người dùng
import 'package:cloud_firestore/cloud_firestore.dart'; // Thư viện Firestore để làm việc với cơ sở dữ liệu đám mây
import 'package:flutter/services.dart';

class AddIngredientPage extends StatefulWidget {
  final Function(Ingredient)
      onAddIngredient; // Callback để cập nhật bảng DataTable
  final VoidCallback onCancel; // Định nghĩa callback onCancel
  const AddIngredientPage(
      {super.key, required this.onAddIngredient, required this.onCancel});

  @override
  _AddIngredientPageState createState() => _AddIngredientPageState();

  static Future<void> openAddIngredientDialog(
    BuildContext context,
    Function(Ingredient) onAddIngredient,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm nguyên liệu'),
          content: AddIngredientPage(
            onAddIngredient: onAddIngredient,
            onCancel: () {
              Navigator.of(context).pop(); // Implement onCancel action
            },
          ),
        );
      },
    );
  }
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _numerController = TextEditingController();
  String _selectedUnit = '';
  String _selectedCategoryId = '';
  List<Category_Ingredient> categories =
      []; // Danh sách các danh mục nguyên liệu từ Firestore
  final List<String> _units = [
    'Gram',
    'Kilogram',
    'Cái',
    'Bịt',
    'Thùng',
  ];
  bool _isLoading = false; // Biến để xác định trạng thái xử lý

  @override
  void initState() {
    super.initState();
    loadCategory_Ingredients();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _numerController.dispose();
    super.dispose();
  }

  void loadCategory_Ingredients() async {
    List<Category_Ingredient> fetchedCategories =
        await fetchloadCategory_IngredientsFromFirestore();
    setState(() {
      categories = fetchedCategories;
    });
  }

  void _addIngredient() async {
    if (_isLoading || !mounted) return;
    String name = _nameController.text.trim();
    double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    int number = int.tryParse(_numerController.text.trim()) ?? 0;

    if (name.isNotEmpty &&
        price > 0 &&
        number > 0 &&
        _selectedCategoryId.isNotEmpty &&
        _selectedUnit.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('ingredients').add({
          'name': name,
          'price': price,
          'number': number,
          'id_category_ingredient': _selectedCategoryId,
          'id_unit_ingredient': _selectedUnit,
          'create_time': DateTime.now(),
          'update_time': null,
          'delete_time': null,
        });

        Ingredient newIngredient = Ingredient(
          id: docRef.id,
          name: name,
          price: price,
          number: number,
          id_category_ingredient: _selectedCategoryId,
          id_unit_ingredient: _selectedUnit,
          create_time: DateTime.now(),
          update_time: null,
          delete_time: null,
        );

        widget.onAddIngredient(newIngredient);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm nguyên liệu thành công!'),
          ),
        );

        _nameController.clear();
        _priceController.clear();
        _numerController.clear();
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm nguyên liệu thất bại: $error'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin nguyên liệu.'),
        ),
      );
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
                  content: const Text('Đang thêm nguyên liệu, vui lòng đợi...'),
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
                DropdownButtonFormField<String>(
                  value:
                      _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
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
                    labelText: 'Tên nguyên liệu',
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
                TextField(
                  controller: _numerController,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng',
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
                  value: _selectedUnit.isEmpty ? null : _selectedUnit,
                  items: _units.map((String unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedUnit = newValue ?? '';
                          });
                        },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addIngredient,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Thêm nguyên liệu'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : widget.onCancel,
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ),
        ));
  }
}
