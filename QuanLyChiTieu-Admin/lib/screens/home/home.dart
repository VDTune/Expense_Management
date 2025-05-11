import 'package:flutter/material.dart';
import '../../services/home_service.dart';
import 'categories.dart'; // Import the CategoriesScreen
import 'users_screen.dart'; // Import the UsersScreen

class HomeScreen extends StatelessWidget {
  final HomeService _homeService = HomeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Overview'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStreamCard('Users', Icons.people, _homeService.getUserCount(), context, isUsers: true),
                  _buildStreamCard('Transactions', Icons.swap_horiz, _homeService.getTransactionCount(), context),
                  _buildStreamCard('Credit', Icons.credit_card, _homeService.getTotalCredit(), context),
                  _buildStreamCard('Debit', Icons.money_off, _homeService.getTotalDebit(), context),
                  _buildStreamCard('Category', Icons.category, _homeService.getCategoryCount(), context, isCategory: true),
                  _buildStreamCard('Online Users', Icons.online_prediction, _homeService.getOnlineUserCount(), context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamCard(String title, IconData icon, Stream<int> stream, BuildContext context, {bool isCategory = false, bool isUsers = false}) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard(title, icon, 'Loading...', context, isCategory: isCategory, isUsers: isUsers);
        } else if (snapshot.hasError) {
          return _buildCard(title, icon, 'Error', context, isCategory: isCategory, isUsers: isUsers);
        } else {
          return _buildCard(title, icon, snapshot.data.toString(), context, isCategory: isCategory, isUsers: isUsers);
        }
      },
    );
  }

  Widget _buildCard(String title, IconData icon, String value, BuildContext context, {bool isCategory = false, bool isUsers = false}) {
    return GestureDetector(
      onTap: () {
        if (isCategory) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoriesScreen()),
          );
        } else if (isUsers) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UsersScreen()),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.blue,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}