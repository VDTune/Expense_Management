import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../utils/app_icons.dart';

class CategoryDropdown extends StatefulWidget {
  final String? cattype;
  final ValueChanged<String?> onChanged;

  const CategoryDropdown({super.key, this.cattype, required this.onChanged});

  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  String? selectedCategory;

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.cattype;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Lỗi khi tải danh sách");
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text("Không có danh mục");
        }

        final categories = snapshot.data!;

        bool isValidValue = categories.any((e) => e['name'] == selectedCategory);
        if (!isValidValue && categories.isNotEmpty) {
          selectedCategory = categories[0]['name'];
          widget.onChanged(selectedCategory);
        }

        return DropdownButtonFormField<String>(
          value: selectedCategory,
          isExpanded: true,
          hint: Text("Chọn danh mục"),
          items: categories.map((e) {
            final iconName = e['icon'] ?? 'ellipsis';
            print("Icon name for ${e['name']}: $iconName"); // Debug
            return DropdownMenuItem<String>(
              value: e['name'],
              child: Row(
                children: [
                  Icon(
                    AppIcons.getIconByName(iconName),
                    color: Colors.black26,
                  ),
                  SizedBox(width: 10),
                  Text(
                    e['name'],
                    style: TextStyle(color: Colors.black26),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedCategory = newValue;
            });
            widget.onChanged(newValue);
            print("Selected category changed to: $newValue"); // Debug
          },
          decoration: InputDecoration(labelText: 'Danh mục'),
          validator: (value) => value == null ? 'Vui lòng chọn danh mục' : null,
        );
      },
    );
  }
}