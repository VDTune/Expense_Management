import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/screens/home/widgets/transaction_details.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../utils/icons_list.dart';

class TransactionCard extends StatelessWidget {
  final dynamic data;

  TransactionCard({
    required this.data,
  });

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

    String formattedDate = DateFormat('d MMM hh:mma').format(date);
    final String formattedAmount = currencyFormat.format(data['amount']);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TransactionDetailsScreen(data: data),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 10),
                color: Colors.grey.withOpacity(0.09),
                blurRadius: 10.0,
                spreadRadius: 4.0,
              ),
            ],
          ),
          child: ListTile(
            minVerticalPadding: 10,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            leading: Container(
              width: 70,
              height: 100,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: data['type'] == 'credit'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                ),
                child: Center(
                  child: FaIcon(
                    appIcons.getExpenseCategoryIcons('${data['category']}'),
                    color: data['type'] == 'credit' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    '${data['title']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "${data['type'] == 'credit' ? '+' : '-'} $formattedAmount",
                  style: TextStyle(
                    color: data['type'] == 'credit' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Số dư",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    Spacer(),
                    Text(
                      currencyFormat.format(data['remainingAmount']),
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


