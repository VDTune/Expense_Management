import 'package:expense_tracker/screens/transactions/widgets/category_list.dart';
import 'package:expense_tracker/screens/transactions/widgets/time_line_month.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../home/add_transaction_screen/add_transaction_form.dart';
import 'widgets/tab_bar_view.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  var category = "Tất cả";
  var monthYear = "";
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  _dialogBuilder(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: AddTransactionForm(),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    setState(() {
      monthYear = DateFormat('M/y').format(now);
    });
  }

  void _startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      isSearching = false;
      searchController.clear();
    });
  }

  void _searchTransactions(String query) {
    print("Searching for: $query");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _dialogBuilder(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent.shade100,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent.shade100,
        title: !isSearching
            ? Text("Giao dịch", style: TextStyle(color: Colors.white))
            : TextField(
                controller: searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search transactions...",
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
                onChanged: (query) => _searchTransactions(query),
              ),
        actions: [
          IconButton(
            onPressed: () {
              if (isSearching) {
                _stopSearch();
              } else {
                _startSearch();
              }
            },
            icon: Icon(isSearching ? Icons.close : Icons.search),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TimeLineMonth(
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    monthYear = value;
                  });
                }
              },
            ),
            // CategoryList(
            //   onChanged: (String? value) {
            //     if (value != null) {
            //       setState(() {
            //         category = value;
            //       });
            //     }
            //   },
            // ),
            TypeTabBar(
              category: category,
              monthYear: monthYear,
              searchQuery: searchController.text,
            ),
          ],
        ),
      ),
    );
  }
}
