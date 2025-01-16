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
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'Domius',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // Show home page if user is logged in
            if (snapshot.hasData && snapshot.data != null) {
              return const HomePage();
            }
            
            // Show login screen if user is not logged in
            return const LoginScreen();
          },
        ),
        // Add error handling for when the app fails to initialize
        builder: (context, child) {
          return child ?? const Scaffold(
            body: Center(
              child: Text('Something went wrong'),
            ),
          );
        },
      ),
    );
  }
}

// Error widget configuration for development
class _ErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const _ErrorWidget({
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'An error occurred',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorDetails.exceptionAsString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}