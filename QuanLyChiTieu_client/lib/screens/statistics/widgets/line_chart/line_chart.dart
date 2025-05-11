import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class LineChartPage extends StatefulWidget {
  @override
  _LineChartPageState createState() => _LineChartPageState();
}

class _LineChartPageState extends State<LineChartPage> {
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
    final userId = FirebaseAuth.instance.currentUser!.uid;

    NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: Text('Biểu đồ tài chính',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 500,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                sliver: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('transactions')
                      .where('monthyear',
                          isEqualTo: DateFormat('M/y').format(currentMonth))
                      .orderBy('timestamp', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(child: Text('Lỗi tìm nạp dữ liệu')),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(child: Text('Chưa có giao dịch')),
                      );
                    } else {
                      List<FlSpot> dataPoints = [];
                      Map<double, String> labels =
                          {}; // Lưu nhãn cho từng điểm dữ liệu

                      for (var doc in snapshot.data!.docs) {
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;
                        int timestamp = data['timestamp'];
                        double? remainingAmount =
                            data['remainingAmount']?.toDouble();
                        String monthYear = data['monthyear'];

                        print(
                            'Document ID: ${doc.id}, Timestamp: $timestamp, Remaining Amount: $remainingAmount, MonthYear: $monthYear');

                        if (remainingAmount != null && !remainingAmount.isNaN) {
                          // Check if the timestamp is in seconds and convert to milliseconds if necessary
                          if (timestamp < 10000000000) {
                            // Roughly corresponds to a timestamp in seconds
                            timestamp *= 1000;
                          }
                          double xValue = timestamp.toDouble();
                          dataPoints.add(FlSpot(xValue, remainingAmount));
                          labels[xValue] =
                              '${currencyFormat.format(remainingAmount)}\n$monthYear'; // Format the currency
                        }
                      }

                      // Sắp xếp các điểm dữ liệu theo timestamp theo thứ tự tăng dần
                      dataPoints.sort((a, b) => a.x.compareTo(b.x));

                      if (dataPoints.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Center(
                              child: Text('Không có dữ liệu sẵn cho biểu đồ')),
                        );
                      }
                      return SliverToBoxAdapter(
                        child: Container(
                          height: 300,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border:
                                    Border.all(color: Colors.black12, width: 1),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: dataPoints,
                                  isCurved: false, // Chỉnh line thẳng
                                  color: Colors.blue, // Màu của line
                                  barWidth: 4,
                                  belowBarData: BarAreaData(show: false),
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.blue,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                ),
                              ],
                              minX: dataPoints.first.x,
                              maxX: dataPoints.last.x,
                              minY: dataPoints
                                  .map((spot) => spot.y)
                                  .reduce((a, b) => a < b ? a : b),
                              maxY: dataPoints
                                  .map((spot) => spot.y)
                                  .reduce((a, b) => a > b ? a : b),
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems:
                                      (List<LineBarSpot> touchedSpots) {
                                    return touchedSpots.map((touchedSpot) {
                                      final text = labels[touchedSpot.x];
                                      return LineTooltipItem(
                                        text!,
                                        TextStyle(color: Colors.white),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          ),
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
