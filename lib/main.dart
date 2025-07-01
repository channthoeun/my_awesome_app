import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:my_awesome_app/providers/auth_provider.dart';
import 'package:my_awesome_app/screens/home_screen.dart';
import 'package:my_awesome_app/screens/login_screen.dart';
import 'package:my_awesome_app/screens/splash_screen.dart';
import 'package:my_awesome_app/utils/app_routes.dart';
import 'package:provider/provider.dart';

// --- ADD THIS LOGGER SETUP FUNCTION ---
void _setupLogging() {
  // Set the root logger level. You can control the verbosity here.
  // Level.ALL shows all logs, Level.OFF disables all.
  Logger.root.level = Level.ALL;

  // Set up a listener to handle log records.
  Logger.root.onRecord.listen((record) {
    // Only print logs in debug mode to avoid leaking info in release builds.
    if (kDebugMode) {
      // A simple formatted output
      print(
          '${record.level.name}: ${record.time}: [${record.loggerName}] ${record.message}');

      // Print error and stack trace if they exist
      if (record.error != null) {
        print('  ERROR: ${record.error}');
      }
      if (record.stackTrace != null) {
        print('  STACK TRACE: ${record.stackTrace}');
      }
    }
  });
}

Future<void>  main() async {
  // It's good practice to call setup functions before runApp
  _setupLogging(); // <-- Call the setup function

  // Get a logger for the main function itself
  final log = Logger('main');
  log.info("App starting...");

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