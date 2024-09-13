import 'package:chats/Pages/chat_page.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String receiverDisplayName;
  final String receiverEmail;
  final String receiverId;
  final String lastMessage;
  final String formattedTime;
  final bool isDarkMode;

  const UserTile({
    super.key,
    required this.receiverDisplayName,
    required this.receiverEmail,
    required this.receiverId,
    required this.lastMessage,
    required this.formattedTime,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary, // Background color of the card
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4), // Shadow offset
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16), // Padding inside the ListTile
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              receiverDisplayName,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ), // Display the receiver's display name
            Text(
              formattedTime, // Display the formatted timestamp
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        subtitle: Text(
          lastMessage,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ), // Display the last message
        onTap: () {
          // Navigate to ChatPage with receiver's email and UID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverUserEmail: receiverEmail,
                receiverUserID: receiverId,
              ),
            ),
          );
        },
      ),
    );
  }
}
