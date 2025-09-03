import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sillswap/screens/chat_screen.dart';

class MatchingScreen extends StatefulWidget {
  final String currentUserId;

  const MatchingScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _MatchingScreenState createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> matches = [];
  Set<String> _followedUserIds = {};

  @override
  void initState() {
    super.initState();
    _findMatches();
  }

  Future<void> _toggleFollow(String otherUserId) async {
    final followingRef = _firestore
        .collection('users')
        .doc(widget.currentUserId)
        .collection('following')
        .doc(otherUserId);

    final followersRef = _firestore
        .collection('users')
        .doc(otherUserId)
        .collection('followers')
        .doc(widget.currentUserId);

    if (_followedUserIds.contains(otherUserId)) {
      await followingRef.delete();
      await followersRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unfollowed user')));
      setState(() {
        _followedUserIds.remove(otherUserId);
      });
    } else {
      await followingRef.set({'timestamp': FieldValue.serverTimestamp()});
      await followersRef.set({'timestamp': FieldValue.serverTimestamp()});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Followed user')));
      setState(() {
        _followedUserIds.add(otherUserId);
      });
    }
  }
  
  void _startChat(BuildContext context, String otherUserId) {
    String chatId = widget.currentUserId.compareTo(otherUserId) < 0
        ? "${widget.currentUserId}_${otherUserId}"
        : "${otherUserId}_${widget.currentUserId}";

    _firestore.collection('chats').doc(chatId).set({
      'participants': [widget.currentUserId, otherUserId],
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          currentUserId: widget.currentUserId,
          otherUserId: otherUserId,
        ),
      ),
    );
  }

  Future<void> _findMatches() async {
    setState(() => isLoading = true);

    final followingSnapshot = await _firestore
        .collection('users')
        .doc(widget.currentUserId)
        .collection('following')
        .get();
    
    _followedUserIds = followingSnapshot.docs.map((doc) => doc.id).toSet();

    final currentUserDoc =
        await _firestore.collection('users').doc(widget.currentUserId).get();
    final currentUser = currentUserDoc.data()!;
    final List<String> skillsToLearn =
        List<String>.from(currentUser['skillsToLearn'] ?? [])
            .map((s) => s.toLowerCase())
            .toList();
    final List<String> skillsToTeach =
        List<String>.from(currentUser['skillsToTeach'] ?? [])
            .map((s) => s.toLowerCase())
            .toList();

    final querySnapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> tempMatches = [];

    for (var doc in querySnapshot.docs) {
      if (doc.id == widget.currentUserId) continue;

      if (_followedUserIds.contains(doc.id)) continue;

      final other = doc.data();
      final otherSkillsToLearn = List<String>.from(other['skillsToLearn'] ?? [])
          .map((s) => s.toLowerCase())
          .toList();
      final otherSkillsToTeach = List<String>.from(other['skillsToTeach'] ?? [])
          .map((s) => s.toLowerCase())
          .toList();

      bool canTeachThem =
          skillsToTeach.any((skill) => otherSkillsToLearn.contains(skill));
      bool canLearnFromThem =
          skillsToLearn.any((skill) => otherSkillsToTeach.contains(skill));

      if (canTeachThem && canLearnFromThem) {
        tempMatches.add({
          'uid': doc.id,
          'name': other['name'],
          'skillsToTeach': other['skillsToTeach'],
          'skillsToLearn': other['skillsToLearn'],
        });
      }
    }

    setState(() {
      matches = tempMatches;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Skill Matches")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : matches.isEmpty
              ? const Center(child: Text("No new matches found."))
              : ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final user = matches[index];
                    final bool isFollowing = _followedUserIds.contains(user['uid']);

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(user['name']),
                        subtitle: Text(
                          "Teaches: ${user['skillsToTeach'].join(", ")}\n"
                          "Learns: ${user['skillsToLearn'].join(", ")}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => _toggleFollow(user['uid']),
                              child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _startChat(context, user['uid']),
                              child: const Text("Message"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

