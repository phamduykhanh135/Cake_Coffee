// import 'package:cake_coffee/models/khanh/area.dart';
// import 'package:cake_coffee/models/khanh/table.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/services.dart';

// class EditTablePage extends StatefulWidget {
//   final Tables table;
//   final Function(Tables) onUpdateTable;
//   final Function(String) onDeleteTable;

//   const EditTablePage({
//     super.key,
//     required this.table,
//     required this.onUpdateTable,
//     required this.onDeleteTable,
//   });

//   static Future<void> openEditProductDialog(
//     BuildContext context,
//     Tables table,
//     Function(Tables) onUpdateTable,
//     Function(String) onDeleteTable,
//   ) async {
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return EditTablePage(
//           table: table,
//           onUpdateTable: onUpdateTable,
//           onDeleteTable: onDeleteTable,
//         );
//       },
//     );
//   }

//   @override
//   _EditTablePage createState() => _EditTablePage();
// }

// class _EditTablePage extends State<EditTablePage> {
//   late TextEditingController _nameController;
//   late TextEditingController _idController;
//   String _selectedAreaId = '';
//   bool _isEditing = false;
//   List<Area> areas = [];

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.table.name);
//     _idController = TextEditingController(text: widget.table.id);
//     _selectedAreaId = widget.table.id_area ?? '';
//     loadAreas();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _idController.dispose();
//     super.dispose();
//   }

//   void loadAreas() async {
//     try {
//       List<Area> fetchedAreas = await fetchAreasFromFirestore();
//       setState(() {
//         areas = fetchedAreas;
//       });
//     } catch (e) {
//       print('Tải danh mục thất bại: $e');
//     }
//   }

//   void _editTable(String tableId) async {
//     setState(() {
//       _isEditing = true;
//     });

//     String name = _nameController.text.trim();

//     // Kiểm tra tên bàn đã tồn tại hay chưa
//     QuerySnapshot existingTableSnapshot = await FirebaseFirestore.instance
//         .collection('tables')
//         .where('name', isEqualTo: name)
//         .get();

//     if (existingTableSnapshot.docs.isNotEmpty &&
//         existingTableSnapshot.docs.first.id != tableId) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Tên bàn đã tồn tại, vui lòng chọn tên khác.'),
//         ),
//       );
//       setState(() {
//         _isEditing = false;
//       });
//       return;
//     }
//     if (name.length > 3) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Chiều dài tối đa là 3 số!.'),
//         ),
//       );
//       setState(() {
//         _isEditing = false;
//       });
//       return;
//     }

//     try {
//       Map<String, dynamic> updatedData = {
//         'name': name,
//         'id_area': _selectedAreaId,
//       };

//       await FirebaseFirestore.instance
//           .collection('tables')
//           .doc(tableId)
//           .update(updatedData);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Cập nhật thành công!'),
//         ),
//       );

//       setState(() {
//         _isEditing = false;
//         widget.table.name = name;
//         widget.table.id_area = _selectedAreaId;
//       });

//       widget.onUpdateTable(widget.table);

//       Navigator.of(context).pop();
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Cập nhật thất bại!'),
//         ),
//       );
//       setState(() {
//         _isEditing = false;
//       });
//     }
//   }

//   void _deleteTable(String tableId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('tables')
//           .doc(tableId)
//           .delete();

//       widget.onDeleteTable(tableId);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Xóa bàn thành công!'),
//         ),
//       );

//       Navigator.of(context).pop();
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Xóa bàn thất bại!'),
//           //'Xóa bàn thất bại: $error'
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
//                   content: const Text('Đang cập nhật bàn, vui lòng đợi...'),
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
//           title: const Text('Cập nhật bàn'),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 DropdownButtonFormField<String>(
//                   value: _selectedAreaId,
//                   onChanged: _isEditing
//                       ? null
//                       : (String? newValue) {
//                           setState(() {
//                             _selectedAreaId = newValue ?? '';
//                           });
//                         },
//                   items: areas.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category.id,
//                       child: Text(category.name),
//                     );
//                   }).toList(),
//                   decoration: const InputDecoration(
//                     labelText: 'Khu vực',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: _nameController,
//                   enabled: !_isEditing,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.allow(
//                         RegExp(r'[0-9]')), // Chỉ cho phép nhập số
//                   ],
//                   decoration: const InputDecoration(
//                     labelText: 'Tên bàn (chỉ nhập số)',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 const Text(
//                   'Đường dẫn tạo QR bàn :',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8.0),
//                 TextField(
//                   readOnly: true,
//                   controller: TextEditingController(
//                     text:
//                         'https://datn-628de.web.app/menu?id_tables=${_idController.text}',
//                   ),
//                   maxLines:
//                       null, // Cho phép TextField tự động điều chỉnh kích thước chiều cao
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
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
//               onPressed: _isEditing ? null : () => _editTable(widget.table.id),
//               child: _isEditing
//                   ? const CircularProgressIndicator()
//                   : const Text('Lưu'),
//             ),
//             ElevatedButton(
//               onPressed:
//                   _isEditing ? null : () => _deleteTable(widget.table.id),
//               style: ElevatedButton.styleFrom(
//                 iconColor: Colors.red,
//               ),
//               child: const Text('Xóa'),
//             ),
//           ],
//         ));
//   }
// }
import 'package:cake_coffee/models/khanh/area.dart';
import 'package:cake_coffee/models/khanh/table.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class EditTablePage extends StatefulWidget {
  final Tables table;
  final Function(Tables) onUpdateTable;
  final Function(String) onDeleteTable;

  const EditTablePage({
    super.key,
    required this.table,
    required this.onUpdateTable,
    required this.onDeleteTable,
  });

  static Future<void> openEditProductDialog(
    BuildContext context,
    Tables table,
    Function(Tables) onUpdateTable,
    Function(String) onDeleteTable,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditTablePage(
          table: table,
          onUpdateTable: onUpdateTable,
          onDeleteTable: onDeleteTable,
        );
      },
    );
  }

  @override
  _EditTablePage createState() => _EditTablePage();
}

class _EditTablePage extends State<EditTablePage> {
  late TextEditingController _nameController;
  late TextEditingController _idController;
  String _selectedAreaId = '';
  bool _isEditing = false;
  List<Area> areas = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.table.name);
    _idController = TextEditingController(text: widget.table.id);
    _selectedAreaId = widget.table.id_area ?? '';
    loadAreas();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void loadAreas() async {
    try {
      List<Area> fetchedAreas = await fetchAreasFromFirestore();
      setState(() {
        areas = fetchedAreas;
      });
    } catch (e) {
      print('Tải danh mục thất bại: $e');
    }
  }

  void _editTable(String tableId) async {
    setState(() {
      _isEditing = true;
    });

    String name = _nameController.text.trim();

    // Kiểm tra tên bàn đã tồn tại hay chưa
    QuerySnapshot existingTableSnapshot = await FirebaseFirestore.instance
        .collection('tables')
        .where('name', isEqualTo: name)
        .get();

    if (existingTableSnapshot.docs.isNotEmpty &&
        existingTableSnapshot.docs.first.id != tableId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tên bàn đã tồn tại, vui lòng chọn tên khác.'),
        ),
      );
      setState(() {
        _isEditing = false;
      });
      return;
    }
    if (name.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chiều dài tối đa là 3 số!.'),
        ),
      );
      setState(() {
        _isEditing = false;
      });
      return;
    }

    // Kiểm tra trạng thái của bàn
    DocumentSnapshot tableSnapshot = await FirebaseFirestore.instance
        .collection('tables')
        .doc(tableId)
        .get();

    if (tableSnapshot.exists) {
      String status = tableSnapshot.get('status');
      if (status != "Trống") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chỉ có thể chỉnh sửa khi bàn ở trạng thái "Trống".'),
          ),
        );
        setState(() {
          _isEditing = false;
        });
        return;
      }
    }

    try {
      Map<String, dynamic> updatedData = {
        'name': name,
        'id_area': _selectedAreaId,
      };

      await FirebaseFirestore.instance
          .collection('tables')
          .doc(tableId)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công!'),
        ),
      );

      setState(() {
        _isEditing = false;
        widget.table.name = name;
        widget.table.id_area = _selectedAreaId;
      });

      widget.onUpdateTable(widget.table);

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thất bại!'),
        ),
      );
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _deleteTable(String tableId) async {
    // Kiểm tra trạng thái của bàn
    DocumentSnapshot tableSnapshot = await FirebaseFirestore.instance
        .collection('tables')
        .doc(tableId)
        .get();

    if (tableSnapshot.exists) {
      String status = tableSnapshot.get('status');
      if (status != "Trống") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chỉ có thể xóa khi bàn ở trạng thái "Trống".'),
          ),
        );
        return;
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('tables')
          .doc(tableId)
          .delete();

      widget.onDeleteTable(tableId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa bàn thành công!'),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa bàn thất bại!'),
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
                content: const Text('Đang cập nhật bàn, vui lòng đợi...'),
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
        title: const Text('Cập nhật bàn'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedAreaId,
                onChanged: _isEditing
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _selectedAreaId = newValue ?? '';
                        });
                      },
                items: areas.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(category.name),
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
                enabled: !_isEditing,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9]')), // Chỉ cho phép nhập số
                ],
                decoration: const InputDecoration(
                  labelText: 'Tên bàn (chỉ nhập số)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Đường dẫn tạo QR bàn :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextField(
                readOnly: true,
                controller: TextEditingController(
                  text:
                      'https://datn-628de.web.app/menu?id_tables=${_idController.text}',
                ),
                maxLines:
                    null, // Cho phép TextField tự động điều chỉnh kích thước chiều cao
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
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
            onPressed: _isEditing ? null : () => _editTable(widget.table.id),
            child: _isEditing
                ? const CircularProgressIndicator()
                : const Text('Lưu'),
          ),
          ElevatedButton(
            onPressed: _isEditing ? null : () => _deleteTable(widget.table.id),
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
