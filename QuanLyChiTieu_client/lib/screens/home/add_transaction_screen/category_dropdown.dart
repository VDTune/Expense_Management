import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryDropdown extends StatelessWidget {
  CategoryDropdown({super.key, this.cattype, required this.onChanged});
  static const Map<String, IconData> iconMap = {
    'home': FontAwesomeIcons.home,
    'lightbulb': FontAwesomeIcons.lightbulb,
    'shoppingCart': FontAwesomeIcons.shoppingCart,
    'bus': FontAwesomeIcons.bus,
    'film': FontAwesomeIcons.film,
    'heart': FontAwesomeIcons.heart,
    'shieldHalved': FontAwesomeIcons.shieldHalved,
    'piggyBank': FontAwesomeIcons.piggyBank,
    'utensils': FontAwesomeIcons.utensils,
    'shoppingBag': FontAwesomeIcons.shoppingBag,
    'graduationCap': FontAwesomeIcons.graduationCap,
    'gift': FontAwesomeIcons.gift,
    'plane': FontAwesomeIcons.plane,
    'gasPump': FontAwesomeIcons.gasPump,
    'tshirt': FontAwesomeIcons.tshirt,
    'mobileAlt': FontAwesomeIcons.mobileAlt,
    'book': FontAwesomeIcons.book,
    'footballBall': FontAwesomeIcons.footballBall,
    'paw': FontAwesomeIcons.paw,
    'handsHelping': FontAwesomeIcons.handsHelping,
    'chartLine': FontAwesomeIcons.chartLine,
    'music': FontAwesomeIcons.music,
    'paintBrush': FontAwesomeIcons.paintBrush,
    'fileInvoiceDollar': FontAwesomeIcons.fileInvoiceDollar,
    'moneyCheck': FontAwesomeIcons.moneyCheck,
    'fileAlt': FontAwesomeIcons.fileAlt,
    'handshake': FontAwesomeIcons.handshake,
    'baby': FontAwesomeIcons.baby,
    'hammer': FontAwesomeIcons.hammer,
    'dumbbell': FontAwesomeIcons.dumbbell,
    'creditCard': FontAwesomeIcons.creditCard,
    'palette': FontAwesomeIcons.palette,
    'spa': FontAwesomeIcons.spa,
    'broom': FontAwesomeIcons.broom,
    'ticketAlt': FontAwesomeIcons.ticketAlt,
    'ring': FontAwesomeIcons.ring,
    'cocktail': FontAwesomeIcons.cocktail,
    'firstAid': FontAwesomeIcons.firstAid,
    'ellipsis': FontAwesomeIcons.ellipsis,
  };
  final String? cattype;
  final ValueChanged<String?> onChanged;

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
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
        return DropdownButton<String>(
          value: cattype,
          isExpanded: true,
          hint: Text("Chọn loại"),
          items: categories
              .map((e) => DropdownMenuItem<String>(
              value: e['name'], // Đảm bảo Firestore có trường 'name'
              child: Row(
                children: [
                  // Icon(IconData(e['icon'], fontFamily: 'MaterialIcons'), color: Colors.black26), // Chuyển 'icon' thành dạng IconData
                  Icon(iconMap[e['icon']] ?? FontAwesomeIcons.questionCircle, color: Colors.black26),
                  SizedBox(width: 10),
                  Text(
                    e['name'],
                    style: TextStyle(color: Colors.black26),
                  ),
                ],
              )))
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}
