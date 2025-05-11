import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/screens/dashboard.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'db.dart';

class AuthService {
  var db = Db();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // login(data, context) async {
  //   try {
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: data['email'],
  //       password: data['password'],
  //     );
  //     // Navigator.of(context).pushReplacement(
  //     //   MaterialPageRoute(builder: (context) => Dashboard()),
  //     // );
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => Dashboard()),
  //     );
  //   } catch (e) {
  //     showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AlertDialog(
  //             title: Text("Email hoặc mật khẩu không chính xác"),
  //           );
  //         });
  //   }
  // }


  // Future<void> login(Map<String, dynamic> data, BuildContext context) async {
  //   try {
  //     UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: data['email'],
  //       password: data['password'],
  //     );
  //     User? user = userCredential.user;
  //
  //     if (user != null) {
  //       DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  //       if (userDoc.exists && userDoc['role'] == 'admin') {
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => Dashboard()),
  //         );
  //       } else {
  //         _showErrorDialog(context, "Access Denied", "You do not have admin privileges.");
  //       }
  //     }
  //   } catch (e) {
  //     _showErrorDialog(context, "Email or password is incorrect", e.toString());
  //   }
  // }

  Future<void> login(Map<String, dynamic> data, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data['email'],
        password: data['password'],
      );
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          if (userData.containsKey('role') && userData['role'] == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          } else {
            _showErrorDialog(context, "Access Denied", "You do not have admin privileges.");
          }
        } else {
          _showErrorDialog(context, "Error", "User document does not exist.");
        }
      }
    } catch (e) {
      _showErrorDialog(context, "Email or password is incorrect", e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
