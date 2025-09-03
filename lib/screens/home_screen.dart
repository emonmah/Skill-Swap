import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sillswap/screens/login_screen.dart';
import 'package:sillswap/screens/profile_screen.dart';
import 'package:sillswap/screens/matching_screen.dart';
import 'package:sillswap/screens/chatlist_screen.dart';
// Import the new home dashboard screen
import 'package:sillswap/screens/user_home_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // The list of screens that correspond to the bottom navigation bar items
  final List<Widget> _screens = [
    const UserHomeViewScreen(), // 0: Home dashboard
    const ProfileScreen(), // 1: Profile editing
    MatchingScreen(currentUserId: FirebaseAuth.instance.currentUser?.uid ?? ''), // 2: Matches
    ChatListScreen(), // 3: Message list
  ];

  // Handles taps on the bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Handles the logout action
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Use pushAndRemoveUntil to clear the navigation stack so the user can't go back
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Skill Swap"),
        // Prevents the automatic "back" button from appearing
        automaticallyImplyLeading: false,
        // Adds a logout icon button to the top-right of the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      // Displays the currently selected screen from the _screens list
      body: _screens[_selectedIndex],
      // The main navigation bar at the bottom of the screen
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Good for 4+ items
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // A different icon when selected
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: "Matches",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: "Messages",
          ),
        ],
      ),
    );
  }
}

