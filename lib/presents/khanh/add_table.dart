import 'dart:typed_data'; // Thư viện để làm việc với dữ liệu dạng byte (Uint8List)
import 'package:cake_coffee/models/khanh/area.dart';
import 'package:cake_coffee/models/khanh/table.dart';
import 'package:flutter/material.dart'; // Thư viện Flutter để xây dựng giao diện người dùng
import 'package:cloud_firestore/cloud_firestore.dart'; // Thư viện Firestore để làm việc với cơ sở dữ liệu đám mây
import 'package:flutter/services.dart';

class AddTablePage extends StatefulWidget {
  final Function(Tables) onAddTable; // Callback để cập nhật bảng DataTable
  final VoidCallback onCancel; // Define onCancel callback
  const AddTablePage(
      {super.key, required this.onAddTable, required this.onCancel});

  @override
  _AddTablePage createState() => _AddTablePage();

  static Future<void> openAddTableDialog(
    BuildContext context,
    Function(Tables) onAddTable,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm bàn'),
          content: AddTablePage(
            onAddTable: onAddTable,
            onCancel: () {
              Navigator.of(context).pop(); // Implement onCancel action
            },
          ),
        );
      },
    );
  }
}

class _AddTablePage extends State<AddTablePage> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedAreasId = '';
  List<Area> areas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadAreas();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void loadAreas() async {
    List<Area> fetchedAreas = await fetchAreasFromFirestore();
    setState(() {
      areas = fetchedAreas;
    });
  }

  void _addProduct() async {
    if (_isLoading || !mounted) return;
    String name = _nameController.text.trim();
    String status = 'empty';

    setState(() {
      _isLoading = true;
    });

    if (name.isNotEmpty && _selectedAreasId.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('tables')
            .add({'name': name, 'id_area': _selectedAreasId, 'status': status});

        Tables newProduct = Tables(
          id: docRef.id,
          name: name,
          id_area: _selectedAreasId,
          status: status,
        );

        widget.onAddTable(newProduct);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm bàn thành công!'),
          ),
        );

        _nameController.clear();

        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thêm bàn thất bại: $error'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin bàn'),
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
                  content: const Text('Đang thêm bàn, vui lòng đợi...'),
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
                  value: _selectedAreasId.isEmpty ? null : _selectedAreasId,
                  onChanged: _isLoading
                      ? null
                      : (String? newValue) {
                          setState(() {
                            _selectedAreasId = newValue ?? '';
                          });
                        },
                  items: areas.map((areas) {
                    return DropdownMenuItem(
                      value: areas.id,
                      child: Text(areas.name),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Khu vực',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên bàn',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addProduct,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Thêm bàn'),
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
// import 'dart:typed_data';
// import 'package:cake_coffee/models/khanh/area.dart';
// import 'package:cake_coffee/models/khanh/table.dart';
// import 'package:cake_coffee/models/khanh/products.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';

// class AddTablePage extends StatefulWidget {
//   final Function(Tables) onAddTable;
//   final VoidCallback onCancel;

//   const AddTablePage({
//     super.key,
//     required this.onAddTable,
//     required this.onCancel,
//   });

//   @override
//   _AddTablePage createState() => _AddTablePage();

//   static Future<void> openAddTableDialog(
//     BuildContext context,
//     Function(Tables) onAddTable,
//   ) async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Thêm bàn'),
//           content: AddTablePage(
//             onAddTable: onAddTable,
//             onCancel: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class _AddTablePage extends State<AddTablePage> {
//   final TextEditingController _nameController = TextEditingController();
//   String _selectedAreasId = '';
//   List<Area> areas = [];
//   List<OrderItem> orderList = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     loadAreas();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   void loadAreas() async {
//     List<Area> fetchedAreas = await fetchAreasFromFirestore();
//     setState(() {
//       areas = fetchedAreas;
//     });
//   }

//   void _addTable() async {
//     if (_isLoading || !mounted) return;
//     String name = _nameController.text.trim();

//     setState(() {
//       _isLoading = true;
//     });

//     if (name.isNotEmpty && _selectedAreasId.isNotEmpty) {
//       try {
//         DocumentReference docRef =
//             await FirebaseFirestore.instance.collection('tables').add({
//           'name': name,
//           'id_area': _selectedAreasId,
//           'orderList': orderList.map((item) => item.toMap()).toList(),
//           'create_time': DateTime.now(),
//           'update_time': null,
//           'delete_time': null,
//         });

//         Tables newTable = Tables(
//           id: docRef.id,
//           name: name,
//           id_area: _selectedAreasId,
//           orderList: orderList,
//           create_time: DateTime.now(),
//           update_time: null,
//           delete_time: null,
//         );

//         widget.onAddTable(newTable);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Đã thêm bàn thành công!'),
//           ),
//         );

//         _nameController.clear();

//         setState(() {
//           _isLoading = false;
//         });
//       } catch (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Thêm bàn thất bại: $error'),
//           ),
//         );
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Vui lòng điền đầy đủ thông tin bàn'),
//         ),
//       );
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _addOrderItem(Product product, int quantity) {
//     setState(() {
//       orderList.add(OrderItem(product: product, quantity: quantity));
//     });
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
//               value: _selectedAreasId.isEmpty ? null : _selectedAreasId,
//               onChanged: _isLoading
//                   ? null
//                   : (String? newValue) {
//                       setState(() {
//                         _selectedAreasId = newValue ?? '';
//                       });
//                     },
//               items: areas.map((area) {
//                 return DropdownMenuItem(
//                   value: area.id,
//                   child: Text(area.name),
//                 );
//               }).toList(),
//               decoration: const InputDecoration(
//                 labelText: 'Khu vực',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Tên bàn',
//                 border: OutlineInputBorder(),
//               ),
//               enabled: !_isLoading,
//             ),
//             const SizedBox(height: 16.0),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: orderList.length,
//                 itemBuilder: (context, index) {
//                   final orderItem = orderList[index];
//                   return ListTile(
//                     title: Text(orderItem.product.name),
//                     subtitle: Text('Số lượng: ${orderItem.quantity}'),
//                   );
//                 },
//               ),
//             ),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _addTable,
//               child: _isLoading
//                   ? const CircularProgressIndicator()
//                   : const Text('Thêm bàn'),
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: _isLoading ? null : widget.onCancel,
//               child: const Text('Hủy'),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Implement logic to add product and quantity to orderList
//           // For example, open a dialog to select product and input quantity
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
