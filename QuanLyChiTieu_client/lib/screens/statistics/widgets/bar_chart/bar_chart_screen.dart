import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'cash_flow.dart';

class Transaction {
  final double remainingAmount;
  final String monthYear;
  final double totalCredit;
  final double totalDebit;
  final int timestamp;

  Transaction({
    required this.remainingAmount,
    required this.monthYear,
    required this.totalCredit,
    required this.totalDebit,
    required this.timestamp,
  });

  factory Transaction.fromDocument(DocumentSnapshot doc) {
    return Transaction(
      monthYear: doc['monthyear'],
      remainingAmount: doc['remainingAmount'].toDouble(),
      totalCredit: doc['totalCredit'].toDouble(),
      totalDebit: doc['totalDebit'].toDouble(),
      timestamp: doc['timestamp'],
    );
  }
}

class BarChartScreen extends StatefulWidget {
  @override
  _BarChartScreenState createState() => _BarChartScreenState();
}

class _BarChartScreenState extends State<BarChartScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  DateTime currentMonth = DateTime.now();

  void previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    });
  }

  void nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Biểu đồ dòng tiền',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('transactions')
                  .where('monthyear',
                      isEqualTo: DateFormat('M/y').format(currentMonth))
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Chưa có giao dịch'));
                } else {
                  List<Transaction> transactions = snapshot.data!.docs
                      .map((doc) => Transaction.fromDocument(doc))
                      .toList();

                  // Tạo 1 map để lưu trữ giao dịch mới nhất của mỗi monthYear
                  Map<String, Transaction> latestTransactions = {};
                  for (var transaction in transactions) {
                    if (!latestTransactions
                            .containsKey(transaction.monthYear) ||
                        latestTransactions[transaction.monthYear]!
                                .timestamp
                                .compareTo(transaction.timestamp) <
                            0) {
                      latestTransactions[transaction.monthYear] = transaction;
                    }
                  }

                  List<Transaction> combinedTransactionList =
                      latestTransactions.values.toList();
                  combinedTransactionList
                      .sort((a, b) => a.monthYear.compareTo(b.monthYear));

                  double totalCredit = combinedTransactionList.fold(
                      0, (sum, item) => sum + item.totalCredit);
                  double totalDebit = combinedTransactionList.fold(
                      0, (sum, item) => sum + item.totalDebit);
                  double remainingAmount = totalCredit - totalDebit;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: SizedBox(
                          height: 400,
                          child: TransactionBarChart(
                            data: combinedTransactionList,
                            currencyFormat: currencyFormat,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 200, // Example size for CashFlow
                        child: CashFlow(
                          remainingAmount: remainingAmount,
                          totalCredit: totalCredit,
                          totalDebit: totalDebit,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: previousMonth,
              icon: Icon(Icons.arrow_back),
              color: Colors.blueAccent,
            ),
            Text(
              DateFormat('M/y').format(currentMonth),
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: nextMonth,
              icon: Icon(Icons.arrow_forward),
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionBarChart extends StatelessWidget {
  final List<Transaction> data;
  final NumberFormat currencyFormat;

  TransactionBarChart({required this.data, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    double maxY = _calculateMaxY();
    double interval = maxY / 6;

    return BarChart(
      BarChartData(
        barGroups: _buildBarGroups(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Text(
                    data[index].monthYear,
                    style: TextStyle(color: Colors.black, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey, width: 1),
        ),
        gridData: FlGridData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String monthYear = data[group.x.toInt()].monthYear;
              return BarTooltipItem(
                '$monthYear\n',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '${currencyFormat.format(rod.toY)}',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {},
        ),
      ),
    );
  }

  double _calculateMaxY() {
    double maxY = 0;
    for (var transaction in data) {
      if (transaction.totalCredit > maxY) maxY = transaction.totalCredit;
      if (transaction.totalDebit > maxY) maxY = transaction.totalDebit;
    }
    return maxY;
  }

  List<BarChartGroupData> _buildBarGroups() {
    return data.asMap().entries.map((entry) {
      int index = entry.key;
      Transaction transaction = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: transaction.totalCredit,
            color: Colors.green,
          ),
          BarChartRodData(
            toY: transaction.totalDebit,
            color: Colors.red,
          ),
        ],
      );
    }).toList();
  }
}
