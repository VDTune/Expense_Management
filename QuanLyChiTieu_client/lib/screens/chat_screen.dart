import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  final ImagePicker _picker = ImagePicker();

  final String apiKey = 'AIzaSyCHrghQxVBd0eVQXLv_Y9XmXGkDDpWfV8U';

  /// Gửi tin nhắn và xử lý phản hồi từ Gemini
  Future<void> _sendMessage({File? image}) async {
    final message = _controller.text.trim();

    if (message.isNotEmpty || image != null) {
      setState(() {
        _messages.add({
          "text": message.isNotEmpty ? message : null,
          "image": image,
          "isUser": true,
        });
        _isTyping = true;
      });

      try {
        if (image != null) {
          // Xử lý gửi hình ảnh (tạm thời bỏ qua vì API không hỗ trợ ảnh trong đoạn code này)
          _addResponse("Hỗ trợ gửi ảnh sẽ được thêm sau.");
        } else {
          // Gửi yêu cầu văn bản
          final response = await _callGeminiApi(message);
          _addResponse(response);
        }
      } catch (e) {
        print("Lỗi: $e");
        _addResponse("Lỗi khi xử lý yêu cầu: $e");
      } finally {
        _controller.clear();
        setState(() {
          _isTyping = false;
        });
      }
    } else {
      _addResponse("Vui lòng nhập tin nhắn hoặc chọn ảnh.");
    }
  }

  /// Gọi API Gemini trực tiếp bằng package http
  Future<String> _callGeminiApi(String text) async {
    const model = 'gemini-1.5-flash'; // Thay bằng model hợp lệ (ví dụ: gemini-pro hoặc gemini-1.5-flash)
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': text}
              ]
            }
          ],
          // Thêm cấu hình nếu cần
          'generationConfig': {
            'temperature': 0.7,
            'topP': 0.9,
            'maxOutputTokens': 1000,
          },
        }),
      );

      print("Mã trạng thái: ${response.statusCode}");
      print("Phản hồi: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ?? 'Không có phản hồi';
      } else if (response.statusCode == 400) {
        throw Exception(
            "Lỗi 400: Yêu cầu không hợp lệ. Kiểm tra cú pháp hoặc model ($model). Phản hồi: ${response.body}");
      } else if (response.statusCode == 403) {
        throw Exception("Lỗi 403: API Key không hợp lệ hoặc không có quyền truy cập.");
      } else {
        throw Exception("Lỗi ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      throw Exception("Lỗi khi gọi API Gemini: $e");
    }
  }

  /// Thêm phản hồi vào tin nhắn
  void _addResponse(String text) {
    setState(() {
      _messages.add({"text": text, "isUser": false});
      _isTyping = false;
    });
  }

  /// Chọn ảnh từ thư viện và gửi đi
  Future<void> _sendImage() async {
    try {
      final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
      if (imageFile == null) {
        _addResponse("Không chọn được ảnh, vui lòng thử lại.");
        return;
      }
      final image = File(imageFile.path);
      if (!await image.exists()) {
        throw Exception("File ảnh không tồn tại: ${imageFile.path}");
      }
      _sendMessage(image: image);
    } catch (e) {
      _addResponse("Lỗi khi chọn hoặc gửi ảnh: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gemini Chat'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  child: Align(
                    alignment: message["isUser"] ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: message["isUser"] ? Colors.blue.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message["text"] != null)
                            Text(
                              message["text"],
                              style: TextStyle(fontSize: 16),
                            ),
                          if (message["image"] != null)
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      child: Image.file(message["image"]),
                                    );
                                  },
                                );
                              },
                              child: Image.file(
                                message["image"],
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text("Lỗi hiển thị ảnh: $error");
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Gemini đang nhập...',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _sendImage,
                  color: Colors.blue,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}