import 'package:chats/Services/Auth/auth_gate.dart';
import 'package:chats/Services/Auth/auth_service.dart';
import 'package:chats/Themes/light_mode.dart';
import 'package:chats/Themes/theme_provider.dart';
import 'package:chats/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Main function to initialize Firebase and run the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      //themeMode: ThemeMode.system, // Follow system theme 
      //darkTheme: darkTheme,
      //theme: themeProvider.getTheme(), // Use the current theme from ThemeProvider
      home: const AuthGate(), // AuthGate widget handles authentication logic
    );
  }
}


