import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/app_icons.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showCategoryDialog({String? docId, String? initialName, String? initialIcon}) {
    showDialog(
      context: context,
      builder: (context) {
        return _CategoryDialog(
          docId: docId,
          initialName: initialName,
          initialIcon: initialIcon,
          firestore: _firestore,
        );
      },
    );
  }

  void _showDeleteDialog(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xóa danh mục'),
          content: Text('Bạn có chắc muốn xóa danh mục này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                _firestore.collection('categories').doc(docId).delete();
                Navigator.pop(context);
              },
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý danh mục'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCategoryDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Không có danh mục nào.'));
          }

          final categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final docId = category.id;
              final name = category['name'] ?? 'Danh mục không tên';
              final iconName = category['icon'] ?? 'ellipsis';
              final icon = AppIcons.getIconByName(iconName);

              return ListTile(
                leading: Icon(icon),
                title: Text(name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showCategoryDialog(
                        docId: docId,
                        initialName: name,
                        initialIcon: iconName,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(docId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final String? docId;
  final String? initialName;
  final String? initialIcon;
  final FirebaseFirestore firestore;

  _CategoryDialog({this.docId, this.initialName, this.initialIcon, required this.firestore});

  @override
  __CategoryDialogState createState() => __CategoryDialogState();
}

class __CategoryDialogState extends State<_CategoryDialog> {
  late TextEditingController nameController;
  late String selectedIcon;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    selectedIcon = widget.initialIcon ?? AppIcons.iconNames.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.docId == null ? 'Thêm danh mục' : 'Cập nhật danh mục'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Tên danh mục'),
          ),
          DropdownButton<String>(
            value: selectedIcon,
            onChanged: (String? newValue) {
              setState(() {
                selectedIcon = newValue!;
              });
            },
            items: AppIcons.iconNames.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Icon(AppIcons.getIconByName(value)),
                    SizedBox(width: 10),
                    Text(value),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            final name = nameController.text.trim();
            if (name.isNotEmpty && selectedIcon.isNotEmpty) {
              if (widget.docId == null) {
                widget.firestore.collection('categories').add({
                  'name': name,
                  'icon': selectedIcon,
                });
              } else {
                widget.firestore.collection('categories').doc(widget.docId).update({
                  'name': name,
                  'icon': selectedIcon,
                });
              }
              Navigator.pop(context);
            }
          },
          child: Text(widget.docId == null ? 'Thêm' : 'Cập nhật'),
        ),
      ],
    );
  }
}