import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ChatMessage.dart';

class ChatScreen extends StatefulWidget {
  final String userId; // Thêm tham số userId
  final String? predefinedMessage; // Predefined message parameter

  const ChatScreen({super.key, required this.userId, this.predefinedMessage});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  final String apiKey = 'AIzaSyAdnxWY5yt9-2h-qndZlN60IGXHzCdLH0Y';
  final String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';
  late String chatKey; // Khóa lưu trữ cho mỗi người dùng
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    chatKey =
        'chat_messages_${widget.userId}'; // Tạo khóa duy nhất cho mỗi người dùng
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _loadMessages();

    // Automatically send the predefined message if it exists
    if (widget.predefinedMessage != null) {
      sendPrompt(widget.predefinedMessage!);
    }
  }

  Future<void> _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonMessages =
        _messages.map((msg) => json.encode(msg.toJson())).toList();
    await prefs.setStringList(chatKey, jsonMessages);
  }

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonMessages = prefs.getStringList(chatKey);
    setState(() {
      _messages = jsonMessages!
          .map((msg) => ChatMessage.fromJson(json.decode(msg)))
          .toList();
    });
  }

  Future<void> sendPrompt(String prompt) async {
    setState(() {
      _messages.add(ChatMessage(text: prompt, isUser: true));
      isLoading = true;
    });
    await _saveMessages();

    try {
      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final aiResponse = jsonResponse['candidates'][0]['content']['parts'][0]
                ['text'] ??
            'No response received';
        setState(() {
          _messages.add(ChatMessage(text: aiResponse, isUser: false));
          isLoading = false;
        });
        await _saveMessages();
      } else {
        setState(() {
          _messages.add(ChatMessage(
              text: 'Failed to get response: ${response.statusCode}',
              isUser: false));
          isLoading = false;
        });
        await _saveMessages();
      }
    } catch (e) {
      setState(() {
        _messages
            .add(ChatMessage(text: 'An error occurred: $e', isUser: false));
        isLoading = false;
      });
      await _saveMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.network(
                'https://cdn-icons-png.flaticon.com/512/11865/11865326.png',
                width: 24,
                height: 24,
              ), // Placeholder image
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Health • Trò chuyện tự động',
                style: TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis, // Prevents overflow
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Hiển thị tin nhắn mới nhất ở dưới cùng
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (isLoading && index == _messages.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final message = _messages[_messages.length - 1 - index];
                return ChatMessageWidget(message: message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Nhập câu hỏi của bạn tại đây',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        sendPrompt(_controller.text);
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Nếu bạn cảm thấy không khỏe, hãy tìm kiếm sự trợ giúp y tế ngay lập tức. Để báo cáo tác dụng phụ của thuốc hoặc để biết thêm thông tin, vui lòng kiểm tra tại đây: miễn trừ trách nhiệm',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget để hiển thị từng tin nhắn
class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/11865/11865326.png'), // Bot avatar
            ),
          if (!message.isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color:
                    message.isUser ? const Color(0xFF1E1E2D) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                message.text,
                style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/194/194938.png'), // User avatar
            ),
        ],
      ),
    );
  }
}
