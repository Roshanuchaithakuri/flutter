// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'pages/home_page.dart';
import 'pages/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAdBmuBhYUoEYlkr3tM9Y6LPQK73S3SDKo',
      appId: '1:330333368628:android:463b47c4752d98e84e7561',
      messagingSenderId: '330333368628',
      projectId: 'dumius-6f037',
      storageBucket: 'dumius-6f037.firebasestorage.app',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseService>(
          create: (_) => FirebaseService(),
        ),
        ProxyProvider<FirebaseService, AuthService>(
          update: (context, firebaseService, previous) => AuthService(),
        ),
        StreamProvider<User?>(
          create: (context) => context.read<FirebaseService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Domius',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If we have a user, show HomePage
        if (snapshot.hasData && snapshot.data != null) {
          return HomePage();
        }

        // Otherwise, show LoginScreen
        return const LoginScreen();
      },
    );
  }
}