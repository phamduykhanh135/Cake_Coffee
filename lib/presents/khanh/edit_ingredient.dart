import 'package:cake_coffee/models/khanh/category_ingredient.dart';
import 'package:cake_coffee/models/khanh/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditIngredientPage extends StatefulWidget {
  final Ingredient ingredient;
  final Function(Ingredient) onUpdateIngredient;
  final Function(String) onDeleteIngredient;

  const EditIngredientPage({
    super.key,
    required this.ingredient,
    required this.onUpdateIngredient,
    required this.onDeleteIngredient,
  });

  static Future<void> openEditIngredientDialog(
    BuildContext context,
    Ingredient ingredient,
    Function(Ingredient) onUpdateIngredient,
    Function(String) onDeleteIngredient,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditIngredientPage(
          ingredient: ingredient,
          onUpdateIngredient: onUpdateIngredient,
          onDeleteIngredient: onDeleteIngredient,
        );
      },
    );
  }

  @override
  _EditIngredientPageState createState() => _EditIngredientPageState();
}

// class _EditIngredientPageState extends State<EditIngredientPage> {
//   late TextEditingController _nameController;
//   late TextEditingController _priceController;
//   late TextEditingController _numberController;
//   String _selectedUnit = '';
//   String _selectedCategoryId = '';
//   bool _isEditing = false;
//   List<Category_Ingredient> categories = [];
//   final List<String> _units = ['Gram', 'Kilogram', 'Cái', 'Bịt', 'Thùng'];

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.ingredient.name);
//     _priceController =
//         TextEditingController(text: widget.ingredient.price.toString());
//     _numberController =
//         TextEditingController(text: widget.ingredient.quantity.toString());
//     _selectedCategoryId = widget.ingredient.id_category_ingredient ?? '';
//     _selectedUnit = widget.ingredient.id_unit_ingredient ?? '';
//     loadCategories();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _priceController.dispose();
//     _numberController.dispose();
//     super.dispose();
//   }

//   void loadCategories() async {
//     try {
//       List<Category_Ingredient> fetchedCategories =
//           await fetchloadCategory_IngredientsFromFirestore();
//       setState(() {
//         categories = fetchedCategories;
//       });
//     } catch (e) {
//       print('Load categories failed: $e');
//     }
//   }

//   void _editIngredient(String ingredientId) async {
//     setState(() {
//       _isEditing = true;
//     });

//     String name = _nameController.text.trim();
//     int price = int.tryParse(_priceController.text.trim()) ?? 0;
//     int quantity = int.tryParse(_numberController.text.trim()) ?? 0;

//     try {
//       Map<String, dynamic> updatedData = {
//         'name': name,
//         'price': price,
//         'quantity': quantity,
//         'total': quantity * price,
//         'id_category_ingredient': _selectedCategoryId,
//         'id_unit_ingredient': _selectedUnit,
//         'update_time': DateTime.now(),
//       };

//       await FirebaseFirestore.instance
//           .collection('ingredients')
//           .doc(ingredientId)
//           .update(updatedData);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Cập nhật thành công!'),
//         ),
//       );

//       setState(() {
//         _isEditing = false;
//         widget.ingredient.name = name;
//         widget.ingredient.price = price.toDouble();
//         widget.ingredient.quantity = quantity.toDouble();
//         widget.ingredient.id_category_ingredient = _selectedCategoryId;
//         widget.ingredient.id_unit_ingredient = _selectedUnit;
//       });

//       widget.onUpdateIngredient(widget.ingredient);

//       Navigator.of(context).pop();
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Cập nhật thấ bại'),
//           //Failed to update ingredient: $error
//         ),
//       );
//       setState(() {
//         _isEditing = false;
//       });
//     }
//   }

//   void _deleteIngredient(String ingredientId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('ingredients')
//           .doc(ingredientId)
//           .delete();

//       widget.onDeleteIngredient(ingredientId);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Xóa thành công'),
//         ),
//       );

//       Navigator.of(context).pop();
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Xóa thất bại'),
//           //'Failed to delete ingredient: $error'
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async {
//           if (_isEditing) {
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: const Text('Thông báo'),
//                   content:
//                       const Text('Đang cập nhật nguyên liệu, vui lòng đợi...'),
//                   actions: <Widget>[
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(false);
//                       },
//                       child: const Text('Đồng ý'),
//                     ),
//                   ],
//                 );
//               },
//             );
//             return false; // Prevent back navigation if loading
//           }
//           return true;
//         },
//         child: AlertDialog(
//           title: const Text('Cập nhật nguyên liệu'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 DropdownButtonFormField<String>(
//                   value: _selectedCategoryId,
//                   onChanged: _isEditing
//                       ? null
//                       : (String? newValue) {
//                           setState(() {
//                             _selectedCategoryId = newValue ?? '';
//                           });
//                         },
//                   items: categories.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category.id,
//                       child: Text(category.name),
//                     );
//                   }).toList(),
//                   decoration: const InputDecoration(
//                     labelText: 'Danh mục',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _nameController,
//                   enabled: !_isEditing,
//                   decoration: const InputDecoration(
//                     labelText: 'Tên nguyên liệu',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _priceController,
//                   decoration: const InputDecoration(
//                     labelText: 'Giá',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                   enabled: !_isEditing,
//                   inputFormatters: <TextInputFormatter>[
//                     FilteringTextInputFormatter.digitsOnly,
//                   ],
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _numberController,
//                   decoration: const InputDecoration(
//                     labelText: 'Số lượng',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                   enabled: !_isEditing,
//                   inputFormatters: <TextInputFormatter>[
//                     FilteringTextInputFormatter.digitsOnly,
//                   ],
//                 ),
//                 const SizedBox(height: 16.0),
//                 DropdownButtonFormField<String>(
//                   value: _selectedUnit,
//                   onChanged: _isEditing
//                       ? null
//                       : (String? newValue) {
//                           setState(() {
//                             _selectedUnit = newValue ?? '';
//                           });
//                         },
//                   items: _units.map((unit) {
//                     return DropdownMenuItem<String>(
//                       value: unit,
//                       child: Text(unit),
//                     );
//                   }).toList(),
//                   decoration: const InputDecoration(
//                     labelText: 'Đơn vị',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: _isEditing
//                   ? null
//                   : () {
//                       Navigator.of(context).pop();
//                     },
//               child: const Text('Thoát'),
//             ),
//             ElevatedButton(
//               onPressed: _isEditing
//                   ? null
//                   : () => _editIngredient(widget.ingredient.id),
//               child: _isEditing
//                   ? const CircularProgressIndicator()
//                   : const Text('Lưu'),
//             ),
//             ElevatedButton(
//               onPressed: _isEditing
//                   ? null
//                   : () => _deleteIngredient(widget.ingredient.id),
//               style: ElevatedButton.styleFrom(
//                 iconColor: Colors.red,
//               ),
//               child: const Text('Xóa'),
//             ),
//           ],
//         ));
//   }

//   String FormartPrice({required double price}) {
//     String formattedAmount =
//         NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(price);
//     return formattedAmount;
//   }
// }
class _EditIngredientPageState extends State<EditIngredientPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _numberController;
  String _selectedUnit = '';
  String _selectedCategoryId = '';
  late DateTime? _deleteTime;
  bool _isEditing = false;
  List<Category_Ingredient> categories = [];
  final List<String> _units = ['Gram', 'Kilogram', 'Cái', 'Bịt', 'Thùng'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _priceController =
        TextEditingController(text: widget.ingredient.price.toString());
    _numberController =
        TextEditingController(text: widget.ingredient.quantity.toString());
    _selectedCategoryId = widget.ingredient.id_category_ingredient ?? '';
    _selectedUnit = widget.ingredient.id_unit_ingredient ?? '';
    _deleteTime = widget.ingredient.delete_time;
    loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void loadCategories() async {
    try {
      List<Category_Ingredient> fetchedCategories =
          await fetchloadCategory_IngredientsFromFirestore();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print('Load categories failed: $e');
    }
  }

  void _editIngredient(String ingredientId) async {
    setState(() {
      _isEditing = true;
    });

    String name = _nameController.text.trim();
    int price = int.tryParse(_priceController.text.trim()) ?? 0;
    int quantity = int.tryParse(_numberController.text.trim()) ?? 0;

    try {
      Map<String, dynamic> updatedData = {
        'name': name,
        'price': price,
        'quantity': quantity,
        'total': quantity * price,
        'id_category_ingredient': _selectedCategoryId,
        'id_unit_ingredient': _selectedUnit,
        'update_time': DateTime.now(),
        'delete_time': _deleteTime, // Include delete_time here
      };

      await FirebaseFirestore.instance
          .collection('ingredients')
          .doc(ingredientId)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công!'),
        ),
      );

      setState(() {
        _isEditing = false;
        widget.ingredient.name = name;
        widget.ingredient.price = price.toDouble();
        widget.ingredient.quantity = quantity.toDouble();
        widget.ingredient.id_category_ingredient = _selectedCategoryId;
        widget.ingredient.id_unit_ingredient = _selectedUnit;
        widget.ingredient.delete_time =
            _deleteTime; // Update deleteTime in widget.ingredient
      });

      widget.onUpdateIngredient(widget.ingredient);

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thất bại'),
        ),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _deleteIngredient(String ingredientId) async {
    try {
      await FirebaseFirestore.instance
          .collection('ingredients')
          .doc(ingredientId)
          .delete();

      widget.onDeleteIngredient(ingredientId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa thành công'),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa thất bại'),
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
                    const Text('Đang cập nhật nguyên liệu, vui lòng đợi...'),
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
        title: const Text('Cập nhật nguyên liệu'),
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
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _nameController,
                enabled: !_isEditing,
                decoration: const InputDecoration(
                  labelText: 'Tên nguyên liệu',
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
              TextField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Số lượng',
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
                items: _units.map((unit) {
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
              Row(
                children: [
                  const Expanded(
                    child: Text('Hạn dùng:'),
                  ),
                  IconButton(
                    onPressed: _isEditing
                        ? null
                        : () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _deleteTime ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _deleteTime = pickedDate;
                              });
                            }
                          },
                    icon: const Icon(Icons.calendar_today),
                  ),
                  Text(
                    _deleteTime != null
                        ? DateFormat('dd/MM/yyyy').format(_deleteTime!)
                        : 'Chọn ngày',
                  ),
                ],
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
            onPressed:
                _isEditing ? null : () => _editIngredient(widget.ingredient.id),
            child: _isEditing
                ? const CircularProgressIndicator()
                : const Text('Lưu'),
          ),
          ElevatedButton(
            onPressed: _isEditing
                ? null
                : () => _deleteIngredient(widget.ingredient.id),
            style: ElevatedButton.styleFrom(
              iconColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
