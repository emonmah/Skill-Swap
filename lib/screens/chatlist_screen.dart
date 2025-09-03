import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("chats")
            .where("participants", arrayContains: currentUserId)
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No messages yet."));
          }

          var chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index];
              return _ChatListItem(
                key: ValueKey(chat.id),
                chatDoc: chat,
                currentUserId: currentUserId,
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final DocumentSnapshot chatDoc;
  final String currentUserId;

  const _ChatListItem({Key? key, required this.chatDoc, required this.currentUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatData = chatDoc.data() as Map<String, dynamic>?;
 
    if (chatData == null) {
      return const SizedBox.shrink();
    }
    
    final List participants = chatData['participants'] ?? [];
    final String otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) {
      return const SizedBox.shrink();
    }

    final String lastMessage = chatData['lastMessage'] ?? "No messages yet.";

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("users").doc(otherUserId).snapshots(),
      builder: (context, userSnapshot) {

        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return ListTile(
            leading: const CircleAvatar(),
            title: const Text("Loading..."),
            subtitle: Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }

        var userDoc = userSnapshot.data!.data() as Map<String, dynamic>;
        String userName = userDoc['name'] ?? "Unknown User";
        String? profilePicUrl = userDoc['profilePictureUrl'];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: (profilePicUrl != null && profilePicUrl.isNotEmpty)
                ? NetworkImage(profilePicUrl)
                : null,
            child: (profilePicUrl == null || profilePicUrl.isEmpty)
                ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : "?")
                : null,
          ),
          title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatId: chatDoc.id,
                  currentUserId: currentUserId,
                  otherUserId: otherUserId,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

