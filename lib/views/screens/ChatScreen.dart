import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/ChatMessage.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String? predefinedMessage;

  const ChatScreen({super.key, required this.userId, this.predefinedMessage});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  final String apiKey =
      'AIzaSyAG4-JKzTi_teIKXg1Es112RHEuXD4AJ70'; // Replace with your Gemini API key
  final String apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  late String chatKey;
  bool isLoading = false;

  // Suggested health questions
  final List<String> suggestedQuestions = [
    'Các dấu hiệu cảnh báo bệnh tim mạch là gì?',
    'Chỉ số huyết áp bình thường là bao nhiêu?',
    'Làm thế nào để phòng ngừa bệnh tim?',
    'Chế độ ăn tốt cho tim mạch?',
    'Các bài tập tốt cho tim mạch?',
  ];

  final String systemPrompt = '''
Bạn là một trợ lý y tế chuyên về tim mạch và sức khỏe tổng quát. Hãy:
1. Chỉ trả lời các câu hỏi liên quan đến sức khỏe, y tế và bệnh lý
2. Tập trung đặc biệt vào các vấn đề tim mạch
3. Đưa ra lời khuyên và hướng dẫn về cách chăm sóc sức khỏe tim mạch
4. Giải thích các thông số y tế và xét nghiệm liên quan
5. Từ chối trả lời các câu hỏi không liên quan đến y tế
6. Luôn nhắc người dùng tham khảo ý kiến bác sĩ với các trường hợp nghiêm trọng

Đối với các triệu chứng nghiêm trọng như:
- Đau ngực dữ dội
- Khó thở nghiêm trọng
- Đau tim
- Mất ý thức
Hãy trả lời: "CẢNH BÁO KHẨN CẤP: Các triệu chứng của bạn có thể nguy hiểm đến tính mạng. Hãy gọi cấp cứu hoặc đến bệnh viện ngay lập tức."

Nếu câu hỏi không liên quan đến sức khỏe, hãy trả lời: "Tôi chỉ có thể tư vấn về các vấn đề sức khỏe và y tế. Vui lòng đặt câu hỏi liên quan đến sức khỏe."
''';

  @override
  void initState() {
    super.initState();
    chatKey = 'chat_messages_${widget.userId}';
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _loadMessages();
    _showWelcomeMessage();

    if (widget.predefinedMessage != null) {
      sendPrompt(widget.predefinedMessage!);
    }
  }

  void _showWelcomeMessage() {
    const welcomeMessage = '''
Xin chào! Tôi là trợ lý sức khỏe AI, chuyên về tư vấn các vấn đề tim mạch và sức khỏe tổng quát.

Tôi có thể giúp bạn:
• Hiểu về các vấn đề tim mạch
• Giải thích các chỉ số sức khỏe
• Đưa ra lời khuyên về lối sống lành mạnh
• Hướng dẫn phòng ngừa bệnh tim


Bạn có thể bắt đầu bằng cách hỏi bất kỳ câu hỏi nào về sức khỏe.
''';

    setState(() {
      _messages.add(ChatMessage(text: welcomeMessage, isUser: false));
    });
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
    if (jsonMessages != null) {
      setState(() {
        _messages = jsonMessages
            .map((msg) => ChatMessage.fromJson(json.decode(msg)))
            .toList();
      });
    }
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
                {'text': '$systemPrompt\n\nUser question: $prompt'}
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

        const String disclaimer =
            '\n\nLưu ý: Thông tin này chỉ mang tính chất tham khảo. Vui lòng tham khảo ý kiến bác sĩ để được tư vấn chính xác cho trường hợp của bạn.';

        setState(() {
          _messages
              .add(ChatMessage(text: aiResponse + disclaimer, isUser: false));
          isLoading = false;
        });
        await _saveMessages();
      } else {
        setState(() {
          _messages.add(ChatMessage(
              text: 'Không thể kết nối với hệ thống. Vui lòng thử lại sau.',
              isUser: false));
          isLoading = false;
        });
        await _saveMessages();
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
            text: 'Đã xảy ra lỗi. Vui lòng thử lại sau.', isUser: false));
        isLoading = false;
      });
      await _saveMessages();
    }
  }

  Widget _buildSuggestedQuestions() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestedQuestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E2D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                sendPrompt(suggestedQuestions[index]);
              },
              child: Text(
                suggestedQuestions[index],
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
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
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Tư vấn sức khỏe tim mạch',
                style: TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Thông tin quan trọng'),
                  content: const Text(
                    'Ứng dụng này chỉ cung cấp thông tin tham khảo về sức khỏe tim mạch. '
                    'Trong trường hợp khẩn cấp hoặc có các triệu chứng nghiêm trọng, '
                    'vui lòng gọi cấp cứu hoặc đến cơ sở y tế gần nhất ngay lập tức.\n\n'
                    'Số cấp cứu: 115',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đã hiểu'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSuggestedQuestions(),
          Expanded(
            child: ListView.builder(
              reverse: true,
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
                        hintText: 'Nhập câu hỏi về sức khỏe của bạn...',
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
              'Trong trường hợp khẩn cấp, vui lòng gọi ngay số 115 hoặc đến cơ sở y tế gần nhất. '
              'Thông tin được cung cấp chỉ mang tính chất tham khảo.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

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
                  'https://cdn-icons-png.flaticon.com/512/11865/11865326.png'),
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
                  color: message.isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/194/194938.png'),
            ),
        ],
      ),
    );
  }
}
