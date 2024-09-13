import 'package:chats/Components/chat_bubble.dart';
import 'package:chats/Components/my_text_field.dart';
import 'package:chats/Services/Chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Text controller
  final TextEditingController _messageController = TextEditingController();

  // Chat & Auth services
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // For text field focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // Cause a delay so that keyboard has time to show up,
        // Remaining space be calculated,
        // Scroll down
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Scroll controller
  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void sendMessage() async {
    // Only send a message if there is something to send
    if (_messageController.text.isNotEmpty) {
      // Send the message and get the document ID
      String messageId = await _chatService.sendMessage(widget.receiverUserID, _messageController.text);

      // Clear text controller after sending the message
      _messageController.clear();

      // Scroll to the bottom of the chat
      //scrollDown();

      // Optionally, you can do something with the message ID here if needed
      print('Message sent with ID: $messageId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _buildMessageList(),
          ),
          // User input
          _buildMessageInput(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // Build Message List
  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Scroll to bottom when messages are updated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollDown();
        });

        // Return list view
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  // Build Message Item
  Widget _buildMessageItem(QueryDocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Safely retrieve fields from the document
    String senderDisplayName = data['senderDisplayName'] ?? 'Unknown User';
    String message = data['message'] ?? 'No message content';
    Timestamp timestamp = data['timestamp'] ?? Timestamp.now(); // Retrieve or use the current timestamp as a fallback

    // Determine if the message is from the current user
    bool isCurrentUser = data['senderId'] == _firebaseAuth.currentUser!.uid;

    // Set the display name based on whether the message is from the current user
    String displayName = isCurrentUser ? 'You' : senderDisplayName;

    // Align the messages to the right if the sender is the current user, otherwise to the left
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    // Format the timestamp
    String formattedTime = "${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}";

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(displayName), // Display 'You' for current user and receiver's name otherwise
            const SizedBox(height: 5),
            ChatBubble(
              message: message, 
              timestamp: formattedTime, 
              isCurrentUser: isCurrentUser, 
              messageId: document.id, // Pass the message document ID
              userId: data["senderId"], // Sender ID
            ),
            const SizedBox(height: 5),
            Align(
              alignment: isCurrentUser ? Alignment.bottomRight : Alignment.bottomLeft,
            ),
          ],
        ),
      ),
    );
  }

  // Build Message Input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          // Text field
          Expanded(
            child: MyTextField(
              focusNode: myFocusNode,
              controller: _messageController,
              hintText: 'Enter Message',
              obscureText: false,
            ),
          ),
          // Send button
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.all(25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.arrow_upward_rounded),
              iconSize: 40,
            ),
          ),
        ],
      ),
    );
  }
}
