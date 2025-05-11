
import 'package:expense_tracker/screens/profile/profile_screen.dart';
import 'package:expense_tracker/screens/chat_screen.dart';
import 'package:expense_tracker/screens/home/users_screen.dart';
import 'package:expense_tracker/screens/statistics/statistics_screen.dart';
import 'package:expense_tracker/widgets/navbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home/home.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var isLogoutLoading = false;
  int currentIndex = 0;
  final List<Widget> pageViewList = [
    HomeScreen(),
    StatisticsScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Navbar(
        selectedIndex: currentIndex,
        onDestinationSelected: (int value) {
          setState(() {
            currentIndex = value;
          });
        },
      ),
      body: IndexedStack(
        index: currentIndex,
        children: pageViewList,
      ),
    );
  }
}