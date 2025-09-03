import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sillswap/screens/follows_screen.dart';

class UserHomeViewScreen extends StatelessWidget {
  const UserHomeViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('Not logged in.'));
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Could not load user data.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final userName = userData['name'] ?? 'User';
          final skillsToTeach = List<String>.from(userData['skillsToTeach'] ?? []);
          final skillsToLearn = List<String>.from(userData['skillsToLearn'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Welcome message
                Text(
                  'Welcome back, $userName!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

        
                _buildFollowerStats(context, currentUser.uid),
                const Divider(height: 32),

                _buildSkillCard('Skills You Can Teach', skillsToTeach, Icons.school),
                const SizedBox(height: 16),
                _buildSkillCard('Skills You Want to Learn', skillsToLearn, Icons.lightbulb_outline),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildFollowerStats(BuildContext context, String userId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
       
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
              
                builder: (context) => FollowsScreen(userId: userId, initialIndex: 0),
              ),
            );
          },
          child: _buildStatItem('Following',
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('following'),
          ),
        ),
       
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                
                builder: (context) => FollowsScreen(userId: userId, initialIndex: 1),
              ),
            );
          },
          child: _buildStatItem('Followers',
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('followers'),
          ),
        ),
      ],
    );
  }

  
  Widget _buildStatItem(String label, CollectionReference collection) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
       
        StreamBuilder<QuerySnapshot>(
          stream: collection.snapshots(),
          builder: (context, snapshot) {
            final count = snapshot.data?.docs.length.toString() ?? '0';
            return Text(
              count,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }


  Widget _buildSkillCard(String title, List<String> skills, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            if (skills.isEmpty)
              const Text('No skills listed yet.')
            else
             
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: skills.map((skill) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text('• ${skill.trim()}', style: const TextStyle(fontSize: 16)),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

