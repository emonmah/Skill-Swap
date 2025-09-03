import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sillswap/screens/chat_screen.dart';

class FollowsScreen extends StatelessWidget {
  final String userId;
  final int initialIndex;

  const FollowsScreen({
    Key? key,
    required this.userId,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connections'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Following'),
              Tab(text: 'Followers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // "Following" list tab
            _FollowList(
              currentUserId: userId,
              userCollectionStream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('following')
                  .snapshots(),

              isFollowingList: true,
            ),
            _FollowList(
              currentUserId: userId,
              userCollectionStream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('followers')
                  .snapshots(),
             
              isFollowingList: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowList extends StatelessWidget {
  final Stream<QuerySnapshot> userCollectionStream;
  final String currentUserId;
  final bool isFollowingList;

  const _FollowList({
    required this.userCollectionStream,
    required this.currentUserId,
    required this.isFollowingList,
  });


  void _unfollowUser(BuildContext context, String otherUserId) async {
    final firestore = FirebaseFirestore.instance;
   
    await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(otherUserId)
        .delete();
    
    await firestore
        .collection('users')
        .doc(otherUserId)
        .collection('followers')
        .doc(currentUserId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User unfollowed.')),
    );
  }


  void _startChat(BuildContext context, String otherUserId) {
    String chatId = currentUserId.compareTo(otherUserId) < 0
        ? "${currentUserId}_${otherUserId}"
        : "${otherUserId}_${currentUserId}";

    FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'participants': [currentUserId, otherUserId],
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

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
    return StreamBuilder<QuerySnapshot>(
      stream: userCollectionStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        final userDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: userDocs.length,
          itemBuilder: (context, index) {
            final otherUserId = userDocs[index].id;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const SizedBox.shrink();
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                final userName = userData['name'] ?? 'Unknown User';
                final profilePicUrl = userData['profilePictureUrl'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (profilePicUrl != null && profilePicUrl.isNotEmpty)
                        ? NetworkImage(profilePicUrl)
                        : null,
                    child: (profilePicUrl == null || profilePicUrl.isEmpty)
                        ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : "?")
                        : null,
                  ),
                  title: Text(userName),
                  
                  trailing: isFollowingList
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              onPressed: () => _startChat(context, otherUserId),
                              tooltip: 'Message',
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_remove_outlined, color: Colors.redAccent),
                              onPressed: () => _unfollowUser(context, otherUserId),
                              tooltip: 'Unfollow',
                            ),
                          ],
                        )
                      : null,
                );
              },
            );
          },
        );
      },
    );
  }
}

