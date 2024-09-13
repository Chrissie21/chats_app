import 'package:chats/Model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  // Get instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // GET USERS STREAM
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // GET ALL USER STREAMS EXCEPT BLOCKED USERS
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked(String userId) {
    return _firestore
        .collection("Users")
        .doc(userId)
        .collection("BlockedUsers")
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

          // Get the current user's email
          final currentUserEmail = _firebaseAuth.currentUser?.email;

          // Get all users and filter out blocked users and current user
          final usersSnapshot = await _firestore.collection("Users").get();
          return usersSnapshot.docs
              .where((doc) =>
                  doc.data()['email'] != currentUserEmail &&
                  !blockedUserIds.contains(doc.id))
              .map((doc) => doc.data())
              .toList();
        });
  }

  // SEND MESSAGE
  Future<String> sendMessage(String receiverId, String message) async {
    try {
      final String currentUserId = _firebaseAuth.currentUser!.uid;
      final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
      final Timestamp timestamp = Timestamp.now();

      final userDoc = await _firestore.collection('Users').doc(currentUserId).get();
      final String currentUserDisplayName = userDoc.data()?['displayName'] ?? 'Unknown User';

      Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp,
        senderDisplayName: currentUserDisplayName,
      );

      List<String> ids = [currentUserId, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");

      // Add message and get the document reference
      final messageDocRef = await _firestore
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());

      // Return the document ID
      return messageDocRef.id;
    } catch (e) {
      // Handle error
      print('Failed to send message: $e');
      rethrow; // Optionally, rethrow the error to handle it in the calling method
    }
  }

  // GET MESSAGES
  Stream<QuerySnapshot> getMessages(String receiverId, String currentUserId) {
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Fetch messages from the chat room, ordered by timestamp
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  // GET LAST MESSAGE
  Future<Map<String, dynamic>> getLastMessage(String currentUserId, String otherUserId) async {
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {'message': 'No messages yet', 'timestamp': Timestamp.now(), 'messageId': null};
      }

      final lastMessageDoc = querySnapshot.docs.first.data() as Map<String, dynamic>;
      return {
        'message': lastMessageDoc['message'] ?? 'No messages yet',
        'timestamp': lastMessageDoc['timestamp'],
        'messageId': querySnapshot.docs.first.id, // Use document ID as message ID
      };
    } catch (e) {
      // Handle error
      print('Failed to get last message: $e');
      return {'message': 'Error fetching message', 'timestamp': Timestamp.now(), 'messageId': null};
    }
  }

  // REPORT USER
  Future<void> reportUser(String messageId, String userId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      final report = {
        'reportedBy': currentUser?.uid,
        'messageId': messageId,
        'messageOwnedId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('Reports').add(report);
    } catch (e) {
      // Handle error
      print('Failed to report user: $e');
    }
  }

  // BLOCK USER
  Future<void> blockUser(String userId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        throw Exception('No User logged in');
      }

      
      await _firestore
          .collection("Users")
          .doc(currentUser.uid)
          .collection("BlockedUsers")
          .doc(userId)
          .set({});

      notifyListeners();
    } catch (e) {
      // Handle error
      print('Failed to block user: $e');
    }
  }

  // UNBLOCK USER
  Future<void> unblockUser(String userId) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      await _firestore
          .collection("Users")
          .doc(currentUser!.uid)
          .collection("BlockedUsers")
          .doc(userId)
          .delete();
    } catch (e) {
      // Handle error
      print('Failed to unblock user: $e');
    }
  }

  // GET BLOCKED USERS STREAM
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userId) {
    return _firestore
        .collection("Users")
        .doc(userId)
        .collection("BlockedUsers")
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

          final userDocs = await Future.wait(
            blockedUserIds.map((id) => _firestore.collection("Users").doc(id).get())
          );

          return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        });
  }
}
