import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> _getUserImageUrl(String userId) async {
    try {
      return await _storage.ref().child('user_avatars').child('$userId.jpg').getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final userDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              final user = userDocs[index].data() as Map<String, dynamic>;
              final userId = userDocs[index].id;

              return FutureBuilder<String?>(
                future: _getUserImageUrl(userId),
                builder: (context, imageSnapshot) {
                  return Slidable(
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        leading: CircleAvatar(
                          backgroundImage: imageSnapshot.hasData
                              ? NetworkImage(imageSnapshot.data!)
                              : AssetImage('assets/default_avatar.png') as ImageProvider,
                          radius: 30,
                          backgroundColor: Colors.grey.shade200,
                        ),
                        title: Text(
                          user['email'] ?? 'No Email',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailsScreen(userId: userId),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class UserDetailsScreen extends StatelessWidget {
  final String userId;

  UserDetailsScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No data found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: userData['avatarUrl'] != null
                        ? NetworkImage(userData['avatarUrl'])
                        : AssetImage('assets/default_avatar.png') as ImageProvider,
                  ),
                ),
                SizedBox(height: 16),
                Divider(),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.blueAccent),
                  title: Text('Username', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text(userData['username'] ?? 'No Username', style: TextStyle(color: Colors.grey)),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.mail, color: Colors.blueAccent),
                  title: Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text(userData['email'] ?? 'No Email', style: TextStyle(color: Colors.grey)),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.call, color: Colors.blueAccent),
                  title: Text('Phone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  subtitle: Text(userData['phone'] ?? 'No Phone', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}