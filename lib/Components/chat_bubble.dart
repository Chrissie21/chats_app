import 'package:chats/Services/Chat/chat_service.dart';
import 'package:chats/Themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String timestamp; 
  final String messageId;
  final String userId;

  const ChatBubble({
    super.key,
    required this.message,
    required this.timestamp, 
    required this.isCurrentUser, 
    required this.messageId, 
    required this.userId, 
  });
  
  //show options
  void _showOptions (BuildContext context, String messageId, String userId) {
    showModalBottomSheet(
      context: context, 
      builder: (context) {
        return SafeArea(child: Wrap(
          children: [
            // Report message button
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text("Report"),
              onTap: (){
                Navigator.pop(context);
                _reportMessage(context, messageId, userId);
              },
            ),

            // Block user
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text("Block User"),
              onTap: (){
                Navigator.pop(context);
                _blockUser(context, userId);
              },
            ),

            // Cancel user
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text("Cancel"),
              onTap: () => Navigator.pop(context),
            )
          ],

        ));
      }
    );
  }

  // report message 
  void _reportMessage(BuildContext context , String messageId, String userId) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Report Message"),
        content: const Text("Are you sure you want to report this message?"),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel"), 
          ), 

          // Report button 
          TextButton(
            onPressed: () {
              ChatService().reportUser(messageId, userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Message Reported")));
            }, 
            child: const Text("Report"), 
          ),

        ],
      )
    );
  }


  // Block user
  void _blockUser(BuildContext context ,  String userId) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Block User"),
        content: const Text("Are you sure you want to block this user?"),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel"), 
          ), 

          // Block button 
          TextButton(
            onPressed: () {
              ChatService().blockUser(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User Blocked")));
            }, 
            child: const Text("Block"), 
          ),

        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // light vs dark mode for correct bubble color 
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    return GestureDetector(
      onLongPress: (){
        if (!isCurrentUser) {
          //show options
          _showOptions(context, messageId, userId);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isCurrentUser 
          ? (isDarkMode ? Colors.green.shade600 : Colors.green.shade500) 
          : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isCurrentUser ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              timestamp,
              style: TextStyle(
                fontSize: 12,
                color: isCurrentUser ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
