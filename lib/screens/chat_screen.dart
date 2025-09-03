import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserId;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    String message = _messageController.text.trim();
    _messageController.clear();

    // Add message to the collection
    await _firestore
        .collection("chats")
        .doc(widget.chatId)
        .collection("messages")
        .add({
      "senderId": widget.currentUserId,
      "receiverId": widget.otherUserId,
      "text": message,
      "timestamp": FieldValue.serverTimestamp(),
    });

    await _firestore.collection("chats").doc(widget.chatId).set({
      "lastMessage": message,
      "timestamp": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
        title: FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection("users").doc(widget.otherUserId).get(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final userName = userData['name'] ?? 'Chat';
              final profilePicUrl = userData['profilePictureUrl'];

              
              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: (profilePicUrl != null && profilePicUrl.isNotEmpty)
                        ? NetworkImage(profilePicUrl)
                        : null,
                    child: (profilePicUrl == null || profilePicUrl.isEmpty)
                        ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : "?")
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(userName),
                ],
              );
            }
            return const Text("Chat");
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("chats")
                  .doc(widget.chatId)
                  .collection("messages")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No messages yet. Say hello! 👋"),
                  );
                }
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msg = messages[index].data() as Map<String, dynamic>;
                    bool isMe = msg['senderId'] == widget.currentUserId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg['text'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

