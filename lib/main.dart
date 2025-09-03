import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sillswap/firebase_options.dart';
import 'package:sillswap/screens/splash_screen.dart';
import 'package:sillswap/screens/login_screen.dart';
import 'package:sillswap/screens/signup_screen.dart';
import 'package:sillswap/screens/home_screen.dart';
import 'package:sillswap/screens/profile_screen.dart';
import 'package:sillswap/screens/matching_screen.dart';
import 'package:sillswap/screens/chat_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const SkillSwapApp());
}

class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        '/profileSetup': (context) => const ProfileScreen(), 
        '/matching': (context) => MatchingScreen(currentUserId: user?.uid ?? ''),
      },
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

