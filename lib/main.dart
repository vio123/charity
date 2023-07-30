import 'package:charity/screens/add_charity.dart';
import 'package:charity/screens/details_charity_screen.dart';
import 'package:charity/screens/home_page.dart';
import 'package:charity/screens/login_screen.dart';
import 'package:charity/screens/profile_screen.dart';
import 'package:charity/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => const HomePage(),
              settings: const RouteSettings(name: '/'),
              fullscreenDialog: false,
              maintainState: true,
            );
          case '/login':
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
              settings: const RouteSettings(name: '/login'),
              fullscreenDialog: false,
              maintainState: true,
            );
          case '/register':
            return MaterialPageRoute(
              builder: (context) => const RegisterScreen(),
              settings: const RouteSettings(name: '/register'),
              fullscreenDialog: false,
              maintainState: true,
            );
          case '/addCharity':
            User? currentUser = FirebaseAuth.instance.currentUser;
            if(currentUser == null) {
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
                settings: const RouteSettings(name: '/login'),
                fullscreenDialog: false,
                maintainState: true,
              );
            }
            return MaterialPageRoute(
              builder: (context) => const AddCharity(),
              settings: const RouteSettings(name: '/addCharity'),
              fullscreenDialog: false,
              maintainState: true,
            );
          case '/profile':
            User? currentUser = FirebaseAuth.instance.currentUser;
            if(currentUser == null) {
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
                settings: const RouteSettings(name: '/login'),
                fullscreenDialog: false,
                maintainState: true,
              );
            }
            return MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
              settings: const RouteSettings(name: '/profile'),
              fullscreenDialog: false,
              maintainState: true,
            );
        }
        final uri = Uri.parse(settings.name ?? '');
        if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'details') {
          final id = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => DetailsCharityScreen(id: id),
            settings: RouteSettings(name: '/details/$id'),
            fullscreenDialog: false,
            maintainState: true,
          );
        }
      },
    );
  }
}
