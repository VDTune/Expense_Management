import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  StreamSubscription? _streamSubscription;
  final ImagePicker _picker = ImagePicker();

  /// Gửi tin nhắn và xử lý phản hồi từ Gemini
  void _sendMessage({File? image}) async {
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

      // Nếu có hình ảnh, xử lý gửi văn bản và ảnh
      if (image != null) {
        final response = await Gemini.instance.textAndImage(
          text: message,
          images: [await image.readAsBytes()],
        );
        final combinedText = response?.content?.parts?.map((e) => e.text).join(" ") ?? 'Không có phản hồi';

        _addResponse(combinedText);
      } else {
        // Nếu chỉ có văn bản, gửi yêu cầu văn bản
        String combinedResponse = "";
        _streamSubscription = Gemini.instance.streamGenerateContent(message).listen(
              (response) {
            combinedResponse += response.output ?? "";
          },
          onDone: () {
            _addResponse(combinedResponse);
          },
          onError: (error) {
            _addResponse("Xin lỗi, có lỗi xảy ra khi xử lý yêu cầu của bạn.");
          },
        );
      }

      _controller.clear();
    }
  }

  /// Thêm phản hồi của Gemini vào tin nhắn
  void _addResponse(String text) {
    setState(() {
      _messages.add({"text": text, "isUser": false});
      _isTyping = false;
    });
  }

  /// Chọn ảnh từ thư viện và gửi đi
  Future<void> _sendImage() async {
    final XFile? imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      _sendMessage(image: File(imageFile.path));
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
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
          // Danh sách tin nhắn
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

          // Hiển thị "đang nhập..."
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

          // Thanh nhập tin nhắn và nút gửi
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
