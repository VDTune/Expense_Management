import 'dart:math';

import 'package:expense_tracker/screens/transactions/widgets/transaction_list.dart';
import 'package:flutter/material.dart';

class TypeTabBar extends StatelessWidget {
  TypeTabBar(
      {Key? key,
      required this.category,
      required this.monthYear,
      required String searchQuery})
      : super(key: key);

  final String category;
  final String monthYear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 2.0,
      child: SizedBox(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              TabBar(
                tabs: [
                  Tab(text: "Thu"),
                  Tab(text: "Chi"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    TransactionList(
                      category: category,
                      monthYear: monthYear,
                      type: 'credit',
                    ),
                    TransactionList(
                      category: category,
                      monthYear: monthYear,
                      type: 'debit',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
