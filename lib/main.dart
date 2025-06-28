import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_awesome_app/providers/auth_provider.dart';
import 'package:my_awesome_app/screens/home_screen.dart';
import 'package:my_awesome_app/screens/login_screen.dart';
import 'package:my_awesome_app/screens/splash_screen.dart';
import 'package:my_awesome_app/utils/app_routes.dart';
import 'package:provider/provider.dart';

Future<void>  main() async {
  // Load the .env file
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider manages the app's authentication state.
    return ChangeNotifierProvider(
      create: (ctx) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Demo App',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          // Determine the home screen based on authentication state
          home: auth.isAuthenticated
              ? const HomeScreen()
              : FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (ctx, authResultSnapshot) =>
            authResultSnapshot.connectionState ==
                ConnectionState.waiting
                ? const SplashScreen()
                : const LoginScreen(),
          ),
          // Define routes for navigation
          routes: {
            AppRoutes.login: (ctx) => const LoginScreen(),
            AppRoutes.home: (ctx) => const HomeScreen(),
          },
        ),
      ),
    );
  }
}