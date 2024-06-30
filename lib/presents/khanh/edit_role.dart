import 'package:cake_coffee/models/khanh/roles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditRolePage extends StatefulWidget {
  final Roles role;
  final Function(Roles) onUpdateRole;
  final Function(String) onDeleteRole;

  const EditRolePage({
    super.key,
    required this.role,
    required this.onUpdateRole,
    required this.onDeleteRole,
  });

  static Future<void> openEditRoleDialog(
    BuildContext context,
    Roles role,
    Function(Roles) onUpdateRole,
    Function(String) onDeleteRole,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditRolePage(
          role: role,
          onUpdateRole: onUpdateRole,
          onDeleteRole: onDeleteRole,
        );
      },
    );
  }

  @override
  _EditRolePage createState() => _EditRolePage();
}

class _EditRolePage extends State<EditRolePage> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  bool _isRoleInUse = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role.name);
    _checkRoleInUse(widget.role.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkRoleInUse(String roleId) async {
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id_role', isEqualTo: roleId)
        .get();

    setState(() {
      _isRoleInUse = userSnapshot.docs.isNotEmpty;
    });
  }

  void _editRole(String roleId) async {
    setState(() {
      _isEditing = true;
    });

    String name = _nameController.text.trim();

    if (_isRoleInUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Không thể sửa vai trò vì có người dùng đang sử dụng vai trò này.'),
        ),
      );
      setState(() {
        _isEditing = false;
      });
      return;
    }

    try {
      Map<String, dynamic> updatedData = {
        'name': name,
      };

      await FirebaseFirestore.instance
          .collection('roles')
          .doc(roleId)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thành công!'),
        ),
      );

      setState(() {
        _isEditing = false;
        widget.role.name = name;
      });

      widget.onUpdateRole(widget.role);

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

  void _deleteRole(String roleId) async {
    if (_isRoleInUse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Không thể xóa vai trò vì có người dùng đang sử dụng vai trò này.'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('roles').doc(roleId).delete();

      widget.onDeleteRole(roleId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa vai trò thành công!'),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xóa vai trò thất bại: $error'),
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
                  content: const Text('Đang cập nhật vai trò, vui lòng đợi...'),
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
          title: const Text('Cập nhật vai trò'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  enabled: !_isRoleInUse && !_isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Tên vai trò',
                    border: OutlineInputBorder(),
                  ),
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
              onPressed: _isEditing || _isRoleInUse
                  ? null
                  : () => _editRole(widget.role.id),
              child: _isEditing
                  ? const CircularProgressIndicator()
                  : const Text('Lưu'),
            ),
            ElevatedButton(
              onPressed: _isEditing ? null : () => _deleteRole(widget.role.id),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Xóa'),
            ),
          ],
        ));
  }
}
