import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../utils/icons_list.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final dynamic data;

  TransactionDetailsScreen({super.key, required this.data});

  final NumberFormat currencyFormat =
  NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final AppIcons appIcons = AppIcons();

  @override
  Widget build(BuildContext context) {
    DateTime date;

    // Kiểm tra và chuyển đổi từ Timestamp sang DateTime
    if (data['date'] is Timestamp) {
      date = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      date = DateTime.parse(data['date']);
    } else {
      throw Exception("Invalid date format");
    }

    String formattedDate = DateFormat('d MMM yyyy hh:mma').format(date);
    final String formattedAmount = currencyFormat.format(data['amount']);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết giao dịch'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${data['title']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      formattedAmount,
                      style: TextStyle(
                        fontSize: 20,
                        color: data['type'] == 'credit'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    FaIcon(
                      appIcons.getExpenseCategoryIcons('${data['category']}'),
                      color:
                      data['type'] == 'credit' ? Colors.green : Colors.red,
                      size: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              'Thông tin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: FaIcon(appIcons
                        .getExpenseCategoryIcons('${data['category']}')),
                    title: Text('Danh mục'),
                    trailing: Text('${data['category']}'),
                  ),
                  ListTile(
                    leading: Icon(Icons.swap_horiz),
                    title: Text('Loại'),
                    trailing: Text(data['type'] == 'credit' ? 'Thu' : 'Chi'),
                  ),
                  ListTile(
                    leading: Icon(Icons.date_range),
                    title: Text('Ngày'),
                    trailing: Text(formattedDate),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Lựa chọn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.green,
                            child: IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                // Hàm xử lý sửa
                              },
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Sửa',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.red,
                            child: IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () {
                                // Hàm xử lý xóa
                              },
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Xóa',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

