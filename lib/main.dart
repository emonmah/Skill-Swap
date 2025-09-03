import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔹 1. Import the generated Firebase options file
// This file is created by the `flutterfire configure` command and is safe to commit.
import 'package:sillswap/firebase_options.dart';

// Import all your screen files
import 'package:sillswap/screens/splash_screen.dart';
import 'package:sillswap/screens/login_screen.dart';
import 'package:sillswap/screens/signup_screen.dart';
import 'package:sillswap/screens/home_screen.dart';
import 'package:sillswap/screens/profile_screen.dart';
import 'package:sillswap/screens/matching_screen.dart';
import 'package:sillswap/screens/chat_screen.dart';

void main() async {
  // Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔹 2. Initialize Firebase using the secure, platform-specific options
  // This single line of code works for both web and mobile automatically.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const SkillSwapApp());
}

class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a good way to get the user, but it will be null at startup.
    // Screens that need the user ID should get it after login.
    final user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skill Swap',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        // Make sure this points to your main profile screen
        '/profileSetup': (context) => const ProfileScreen(), 
        '/matching': (context) => MatchingScreen(currentUserId: user?.uid ?? ''),
      },
      // This handles passing data to the chat screen
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: args['chatId'],
              currentUserId: args['currentUserId'],
              otherUserId: args['otherUserId'],
            ),
          );
        }
        return null;
      },
    );
  }
}

