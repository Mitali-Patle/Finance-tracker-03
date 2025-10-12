import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/foundation.dart'; // Add this import for kDebugMode


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}
// A new, reusable widget for displaying a chat message bubble.
class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      // Align bubbles to the right for the user, and left for the bot.
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        // Add some margin around the bubble.
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        // Add padding inside the bubble.
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          // Change the color based on the sender.
          color: isUser ? Theme.of(context).primaryColor : Colors.grey[200],
          // Make the corners rounded.
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];


Future<String> getBotResponse(String userMessage) async {
  final formattedUserMessage = userMessage.toLowerCase().trim();
  if (formattedUserMessage.isEmpty) {
    return "Please ask a question.";
  }

  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chatbot_responses')
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc['Question'].toString().toLowerCase().contains(formattedUserMessage)) {
        return doc['answer'];
      }
    }
    
    return "Sorry, I don't understand. Please try another question.";

  } catch (e) {
    // This will catch any errors from Firestore (like permission denied)
    // and print them to your debug console.
    if (kDebugMode) {
      print("Error fetching chatbot response: $e");
    }
    return "Sorry, something went wrong on my end.";
  }
}

  void sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "message": userMessage});
    });

    _controller.clear();

    String botReply = await getBotResponse(userMessage);

    setState(() {
      messages.add({"sender": "bot", "message": botReply});
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Chatbot"),
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            // Add padding so bubbles don't touch the screen edge
            padding: const EdgeInsets.all(8.0),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final bool isUser = message['sender'] == 'user';
              // Use our new, beautiful widget
              return MessageBubble(
                message: message['message']!,
                isUser: isUser,
              );
            },
          ),
        ),
        // The new, styled input area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.05),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Type your message...",
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(30),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: sendMessage,
                ),
              )
            ],
          ),
        )
      ],
    ),
  );
}}