import 'package:cloud_firestore/cloud_firestore.dart';

class HomeService {
  // Lấy tham chiếu đến Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<int> getUserCount() {
    return _firestore.collection('users').snapshots().map((snapshot) => snapshot.size);
  }

  Stream<int> getTransactionCount() {
    return _firestore.collectionGroup('transactions').snapshots().map((snapshot) => snapshot.size);
  }

  Stream<int> getTotalCredit() {
    return _firestore.collection('users').snapshots().map((userSnapshot) {
      int totalCredit = 0;
      for (var userDoc in userSnapshot.docs) {
        totalCredit += (userDoc['totalCredit'] as num).toInt();
      }
      return totalCredit;
    });
  }

  Stream<int> getTotalDebit() {
    return _firestore.collection('users').snapshots().map((userSnapshot) {
      int totalDebit = 0;
      for (var userDoc in userSnapshot.docs) {
        totalDebit += (userDoc['totalDebit'] as num).toInt();
      }
      return totalDebit;
    });
  }

  Stream<int> getCategoryCount() {
    // Theo dõi số lượng tài liệu trong collection "categories"
    return _firestore.collection('categories').snapshots().map((snapshot) {
      // Đếm số lượng tài liệu
      return snapshot.docs.length;
    });
  }

  Stream<int> getOnlineUserCount() {
    return _firestore.collection('users').where('online', isEqualTo: true).snapshots().map((snapshot) => snapshot.size);
  }
}