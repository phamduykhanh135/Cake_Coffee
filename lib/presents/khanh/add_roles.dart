import 'package:cake_coffee/models/khanh/roles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddRolePage extends StatefulWidget {
  final Function(Roles) onAddRole;
  final VoidCallback onCancel;

  const AddRolePage(
      {super.key, required this.onAddRole, required this.onCancel});

  @override
  State<AddRolePage> createState() => _AddRolePageState();

  static Future<void> openAddRoleDialog(
    BuildContext context,
    Function(Roles) onAddRole,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm vai trò'),
          content: AddRolePage(
            onAddRole: onAddRole,
            onCancel: () {
              Navigator.of(context).pop(); // Implement onCancel action
            },
          ),
        );
      },
    );
  }
}

class _AddRolePageState extends State<AddRolePage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

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
                  content: const Text('Đang thêm vai trò, vui lòng đợi...'),
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
                const SizedBox(height: 16.0),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên vai trò',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addRole,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Thêm vai trò'),
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

  Future<void> _addRole() async {
    if (_isLoading || !mounted) return;

    String name = _nameController.text.trim();
    if (name.isNotEmpty) {
      Roles newRole = Roles(
        id: FirebaseFirestore.instance.collection('roles').doc().id,
        name: name,
        create_time: DateTime.now(),
        update_time: null,
        delete_time: null,
      );

      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('roles')
            .doc(newRole.id)
            .set(newRole.toMap());

        widget.onAddRole(newRole);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm vai trò thành công!'),
          ),
        );

        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $error'),
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên vai trò.'),
        ),
      );
    }
  }
}
