import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final chatProvider = ChangeNotifierProvider((ref) => ChatController());

class ChatScreen extends ConsumerWidget {
  static const routeName = '/chat-screen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatController = ref.watch(chatProvider);
    final messageController = TextEditingController();
    final scrollController = ScrollController();

    // Scroll to the bottom after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(scrollController);
    });

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController, // Assign ScrollController
              itemCount: chatController.messages.length,
              itemBuilder: (context, index) {
                final message = chatController.messages[index];
                return message.isUser
                    ? UserMessageCard(message: message.text)
                    : AIMessageCard(message: message.text);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final text = messageController.text;
                    if (text.isNotEmpty) {
                      chatController.sendMessage(text);
                      messageController.clear();
                      // Scroll to the bottom after sending a message
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom(scrollController);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }
}

class ChatMessage {
  final bool isUser;
  final String text;

  ChatMessage({required this.isUser, required this.text});
}

class ChatController extends ChangeNotifier {
  List<ChatMessage> messages = [];

  // Directly include the API key here
  final String apiKey = 'AIzaSyCKOeYxzHf6rfMpScJdeVRxl1sfjlSO7ac';  // Replace with your actual API key
  late final GenerativeModel model;

  ChatController() {
    if (apiKey.isEmpty) {
      throw Exception('API_KEY is empty');
    }
    model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  void sendMessage(String text) async {
    messages.add(ChatMessage(isUser: true, text: text));
    notifyListeners();

    final response = await _fetchResponseFromAI(text);
    if (response != null) {
      messages.add(ChatMessage(isUser: false, text: response));
      notifyListeners();
    }
  }

  Future<String?> _fetchResponseFromAI(String text) async {
    try {
      final content = [Content.text(text)];
      final response = await model.generateContent(content);

      print('Response: ${response.text}');
      return response.text;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}

class UserMessageCard extends StatelessWidget {
  final String message;

  const UserMessageCard({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SelectableText(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class AIMessageCard extends StatelessWidget {
  final String message;

  const AIMessageCard({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: SelectableText(
            message,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
