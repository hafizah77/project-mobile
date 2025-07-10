import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_app/page/loginPage.dart';
import 'package:travel_app/page/homeUserPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCVqDK8V0gTcPfD-B0E-vz3AmDpgoGYlcU",
        authDomain: "travel-app-e27ba.firebaseapp.com",
        projectId: "travel-app-e27ba",
        storageBucket: "travel-app-e27ba.appspot.com",
        messagingSenderId: "710358047344",
        appId: "1:710358047344:web:7fc6411d82ac2bae63b2b5",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialPage() async {
    final prefs = await SharedPreferences.getInstance();
    final hasUser = prefs.containsKey('user_name') && prefs.containsKey('user_email');
    return hasUser ? const HomePage() : const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelKu App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data!;
        },
      ),
    );
  }
}
