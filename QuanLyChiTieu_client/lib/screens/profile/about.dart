import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  About({super.key});

  final String facebookUrl = 'https://www.facebook.com/nvan2903/';

  Uri dialNumber = Uri(scheme: 'tel', path: '0372171784');

  callNumber() async {
    await launchUrl(dialNumber);
  }

  directCall() async {
    await FlutterPhoneDirectCaller.callNumber('0372171784');
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giới thiệu'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ứng dụng quản lý chi tiêu - Sản phẩm học phần phát triển ứng dụng di dộng đa nền tảng\n'
              '\nSinh viên thực hiện: \n'
                  'Võ Đức Tuân \n',

              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Thông tin liên hệ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => _launchURL(facebookUrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.facebook, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        'Đức Tuân',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'voductuan1305@gmail.com',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Màu nền của nút
                    padding:
                        EdgeInsets.zero, // Xóa padding để căn giữa nội dung
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.instagram, color: Colors.pink),
                      // Icon Instagram
                      SizedBox(width: 10),
                      Text(
                        'Instagram',
                        style: TextStyle(color: Colors.white), // Màu chữ
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: callNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call, color: Colors.green),
                      SizedBox(width: 10),
                      Text(
                        '0818741182',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
