import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/screens/home/add_transaction_screen/category_dropdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? transactionData;

  const EditTransactionScreen({
    Key? key,
    this.userData,
    this.transactionData,
  }) : super(key: key);

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  var type = "credit";
  var category = "Khác";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var isLoader = false;
  var amountEditController = TextEditingController();
  var titleEditController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    if (widget.transactionData != null) {
      titleEditController.text = widget.transactionData!['title'];
      amountEditController.text = widget.transactionData!['amount'].toString();
      _selectedDate = widget.transactionData!['date']?.toDate();
      category = widget.transactionData!['category'] ?? "Khác"; // Đảm bảo category không null
      type = widget.transactionData!['type'] ?? "credit"; // Đảm bảo type không null
    }
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser!;
        final String transactionId = widget.transactionData!['id'];
        final int newAmount = int.parse(amountEditController.text);
        final DateTime date = _selectedDate ?? DateTime.now();
        final int newTimestamp = DateTime.now().microsecondsSinceEpoch; // Cập nhật thời gian chỉnh sửa
        final String monthyear = DateFormat('M/y').format(date);

        // Lấy dữ liệu giao dịch hiện tại
        final existingTransactionDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(transactionId)
            .get();

        if (!existingTransactionDoc.exists) {
          throw Exception("Giao dịch không tồn tại");
        }

        final existingTransactionData = existingTransactionDoc.data()!;
        final int oldAmount = existingTransactionData['amount'];
        final String oldType = existingTransactionData['type'];

        // Tính toán thay đổi cho totalCredit, totalDebit, remainingAmount
        int creditChange = 0;
        int debitChange = 0;

        // Hoàn tác giá trị cũ
        if (oldType == 'credit') {
          creditChange -= oldAmount;
        } else {
          debitChange -= oldAmount;
        }

        // Áp dụng giá trị mới
        if (type == 'credit') {
          creditChange += newAmount;
        } else {
          debitChange += newAmount;
        }

        // Cập nhật giao dịch trong Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .doc(transactionId)
            .update({
          'title': titleEditController.text, // Cập nhật tiêu đề
          'amount': newAmount, // Cập nhật số tiền
          'type': type, // Cập nhật loại giao dịch
          'category': category, // Cập nhật danh mục
          'date': date, // Cập nhật ngày
          'timestamp': newTimestamp, // Cập nhật thời gian chỉnh sửa
          'monthyear': monthyear, // Cập nhật tháng/năm
        });

        // Cập nhật tổng số liệu của người dùng
        final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final userSnapshot = await transaction.get(userDoc);
          if (!userSnapshot.exists) {
            throw Exception("Dữ liệu người dùng không tồn tại");
          }

          final userData = userSnapshot.data()!;
          int totalCredit = (userData['totalCredit'] as int) + creditChange;
          int totalDebit = (userData['totalDebit'] as int) + debitChange;
          int remainingAmount = totalCredit - totalDebit;

          transaction.update(userDoc, {
            'totalCredit': totalCredit,
            'totalDebit': totalDebit,
            'remainingAmount': remainingAmount,
            'updatedAt': newTimestamp, // Cập nhật thời gian chỉnh sửa của người dùng
          });
        });

        print("Giao dịch đã được cập nhật: $transactionId, category: $category");

        Navigator.pop(context);
      } catch (e) {
        print("Lỗi khi cập nhật giao dịch: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e")),
        );
      } finally {
        setState(() {
          isLoader = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Chỉnh sửa giao dịch", style: TextStyle(fontSize: 24)),
              TextFormField(
                controller: titleEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề';
                  }
                  return null;
                },
                decoration: InputDecoration(labelText: 'Tiêu đề'),
              ),
              TextFormField(
                controller: amountEditController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Số tiền phải là số nguyên';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Số tiền'),
              ),
              TextButton(
                onPressed: _presentDatePicker,
                child: Text(
                  _selectedDate == null
                      ? 'Chọn ngày'
                      : 'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              CategoryDropdown(
                cattype: category,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      category = value;
                    });
                    print("Category updated to: $category"); // Debug
                  }
                },
              ),
              DropdownButtonFormField<String>(
                value: type,
                items: [
                  DropdownMenuItem(
                    child: Text('Thu'),
                    value: 'credit',
                  ),
                  DropdownMenuItem(
                    child: Text('Chi'),
                    value: 'debit',
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      type = value;
                    });
                    print("Type updated to: $type"); // Debug
                  }
                },
                decoration: InputDecoration(labelText: 'Loại giao dịch'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (!isLoader) {
                    _submitForm();
                  }
                },
                child: isLoader
                    ? Center(child: CircularProgressIndicator())
                    : Text("Lưu thay đổi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}