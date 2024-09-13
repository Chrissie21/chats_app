import 'package:chats/Components/my_drawer.dart';
import 'package:chats/Services/Auth/auth_service.dart';
import 'package:chats/Services/Chat/chat_service.dart'; // Import the chat service
import 'package:chats/Themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instance of FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instance of ChatService to fetch the last message
  final ChatService _chatService = ChatService();

  // Instance of authService
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // Set the height of the AppBar
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff10497E),
                Color(0xff281537),
              ], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // Set background color to transparent
            elevation: 2, // Shadow
            title: const Text(
              'Chats',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
            actions: const [
              Icon(
                Icons.search,
                color: Colors.white,
              ),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
          ),
        ),
      ),
      drawer: const MyDrawer(),
      body: _buildUserList(),
    );
  }

  // Build a list of users excluding the currently logged-in user
  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _getUsersStream(),
      builder: (context, snapshot) {
        // Error case
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching users'));
        }

        // Loading case
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black,));
        }

        // Handle empty user list
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users available'));
        }

        // Build user list items
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final user = snapshot.data![index];
            return _buildUserListItem(user);
          },
        );
      },
    );
  }

  // Get a stream of users sorted by recent activity, excluding the current user
  Stream<List<Map<String, dynamic>>> _getUsersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots().asyncMap((snapshot) async {
      final List<Map<String, dynamic>> sortedUsers = [];

      for (var user in snapshot.docs) {
        final userId = user['uid'];
        if (userId == _auth.currentUser!.uid) continue; // Skip current user

        final lastMessageSnapshot = await _chatService.getLastMessage(_auth.currentUser!.uid, userId);

        // If the last message exists, add it to the user's data
        sortedUsers.add({
          ...user.data(),
          'lastMessage': lastMessageSnapshot['message'] ?? 'No messages yet',
          'timestamp': lastMessageSnapshot['timestamp'],
        });
      }

      // Sort users by the latest message timestamp, putting users with recent messages at the top
      sortedUsers.sort((a, b) {
        final timestampA = (a['timestamp'] as Timestamp?)?.toDate();
        final timestampB = (b['timestamp'] as Timestamp?)?.toDate();
        if (timestampA == null && timestampB == null) return 0;
        if (timestampA == null) return 1;
        if (timestampB == null) return -1;
        return timestampB.compareTo(timestampA);
      });

      return sortedUsers;
    });
  }

  // Build individual user list items
  Widget _buildUserListItem(Map<String, dynamic> data) {
    // Light vs Dark mode
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    final String receiverId = data['uid'];
    final String receiverEmail = data['email'];
    final String receiverDisplayName = data['displayName'] ?? 'Unknown User';
    final String lastMessage = data['lastMessage'] ?? 'No messages yet';
    final Timestamp? timestamp = data['timestamp'];
    final formattedTime = timestamp != null
        ? "${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}"
        : '';

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
              style: TextStyle(color: isDarkMode ? Colors.white : (isDarkMode ? Colors.white : Colors.black),),
            ), // Display the receiver's display name
            Text(
              formattedTime, // Display the formatted timestamp
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
        subtitle: Text(
          lastMessage,
          style: TextStyle(color: isDarkMode ? Colors.white : (isDarkMode ? Colors.white : Colors.black),), 
        
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
