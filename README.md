Skill Swap - A Social Skill-Sharing Mobile App
Skill Swap is a mobile application built with Flutter that connects people who want to learn new skills with those who can teach them. Users can create detailed profiles, find matches based on complementary skills, follow interesting people, and chat in real-time to arrange skill exchanges.

Overview
In a world where everyone has something to teach and something to learn, Skill Swap provides the platform to make those connections. The core idea is to foster a community of mutual growth, moving beyond traditional learning methods. Whether you want to learn to play the guitar from a local musician in exchange for teaching them how to code, find a language partner to practice with, or get photography tips from a pro who wants to learn baking, Skill Swap helps you find the right person. The app is designed to be intuitive and user-friendly, with a focus on detailed user profiles and a smart matching algorithm to foster meaningful, reciprocal connections.

Core Features
Detailed User Profiles: Users can create rich, multi-faceted profiles that serve as the foundation for the matching system. This includes essential information such as:

Basic info (Name, a unique username, and a profile picture to add a personal touch).

Demographics (Age and gender, which can be used for filtering).

A personal bio and a list of hobbies to showcase personality.

Crucially: A dedicated list of skills they are confident in teaching and skills they are eager to learn. This is the core of the matching logic.

Matching preferences like the desired age range of their matches.

Skill-Based Matching: The app’s intelligent matching algorithm is the heart of the experience. It doesn't just show random users; it specifically suggests people who have a mutual interest. It finds users who possess skills you want to learn and, in return, are interested in learning skills that you can teach, creating a perfect foundation for a two-way exchange.

Real-Time Chat: Once you discover a potential match, you can immediately initiate a conversation. The app includes a fully-featured, real-time messaging system powered by Firestore streams. Conversations are displayed with user profile pictures and are automatically sorted by the most recent message, ensuring you never miss the latest reply.

Follow / Unfollow System: Found someone with interesting skills but not ready to connect yet? You can "follow" them to keep their profile bookmarked for later. This feature allows you to build a network of interesting people. You can easily view your "Following" and "Followers" lists and manage your connections by unfollowing users directly from their profile or the connections list.

Cross-Platform: Built with a single, modern codebase using Flutter, the app is designed to provide a seamless and consistent user experience on both Android and web platforms. This ensures wider accessibility and easier maintenance.

Tech Stack
Frontend: Flutter - A powerful framework for building beautiful, natively compiled, multi-platform applications from a single codebase.

Backend & Database: Firebase - A comprehensive suite of tools for building and managing the backend. We use:

Firebase Authentication for secure and easy user login and registration.

Cloud Firestore as our flexible, real-time NoSQL database for storing all user data, chats, and connections.

Image Hosting: ImgBB - A simple and effective third-party service used as a free alternative to Firebase Storage for hosting user profile pictures.

Setup and Installation
To get the project up and running on your local machine for development and testing, please follow these steps:

1. Prerequisites:

Make sure you have the Flutter SDK installed and configured on your machine.

You will need a Google account to create a new project on the Firebase Console.


2. Configure Firebase:

For Android: You will need to follow the Firebase setup instructions to generate a google-services.json file for your Android app. This file contains the necessary keys to connect your app to your Firebase project and should be placed in the android/app/ directory.

For Web/Cross-Platform: The recommended approach is to use the FlutterFire CLI, which simplifies configuration for all platforms. Run flutterfire configure in your project root. This command will generate the lib/firebase_options.dart file, which allows your app to securely initialize its connection to Firebase.

3. Get an ImgBB API Key:

To enable profile picture uploads, this project uses the ImgBB service for free image hosting.

Go to ImgBB.com, create a free account, and navigate to the "About" page to find your unique API key.

Open the lib/screens/profile_screen.dart file and paste this key into the _imgbbApiKey string variable.

4. Install Dependencies:

This command will download all the required packages listed in the pubspec.yaml file.

flutter pub get

5. Run the App:

You can now launch the app on your connected device, emulator, or in a web browser.

flutter run

APK Download Link: https://drive.google.com/file/d/1-O_t67aa6VxdXyfqtzJQT7x3se9jXb4X/view?usp=sharing
