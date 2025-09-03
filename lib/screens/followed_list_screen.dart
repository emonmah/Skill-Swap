import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart'; // To navigate to the chat screen

class FollowedListScreen extends StatefulWidget {
  const FollowedListScreen({Key? key}) : super(key: key);

  @override
  State<FollowedListScreen> createState() => _FollowedListScreenState();
}

class _FollowedListScreenState extends State<FollowedListScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // This function initiates the chat, similar to the old "Connect" button's logic
  void _startChat(BuildContext context, String otherUserId) {
    // Generate a consistent chatId for the two users
    String chatId = currentUserId.compareTo(otherUserId) < 0
        ? "${currentUserId}_${otherUserId}"
        : "${otherUserId}_${currentUserId}";
    
    // Create chat document if it doesn't exist
    FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'participants': [currentUserId, otherUserId],
      'lastMessage': 'Chat started.',
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          currentUserId: currentUserId,
          otherUserId: otherUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Following"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listen to the "following" subcollection of the current user
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('following')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("You are not following anyone yet."));
          }

          var followedDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: followedDocs.length,
            itemBuilder: (context, index) {
              String followedUserId = followedDocs[index].id;

              // Use a FutureBuilder to get the profile details of the followed user
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(followedUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text("Loading..."));
                  }
                  
                  if (!userSnapshot.data!.exists) {
                    return const SizedBox.shrink(); // Hide if user data is missing
                  }

                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      title: Text(userData['name'] ?? 'Unknown User'),
                      trailing: ElevatedButton(
                        onPressed: () => _startChat(context, followedUserId),
                        child: const Text('Chat'),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}