import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/views/SplashScreenUI.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://yxofwqhqhnoywtrwxjvk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4b2Z3cWhxaG5veXd0cnd4anZrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxNTgzNTIsImV4cCI6MjA5MTczNDM1Mn0.Tsqd6w-_9ohgo1bVgV89Mp-zaP0WXnsuUbX7ke-lN2Y',
  );

  runApp(FlutterMoneyTrackingApp());
}

class FlutterMoneyTrackingApp extends StatefulWidget {
  const FlutterMoneyTrackingApp({super.key});

  @override
  State<FlutterMoneyTrackingApp> createState() => _FlutterMoneyTrackingAppState();
}

class _FlutterMoneyTrackingAppState extends State<FlutterMoneyTrackingApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)),
    );
  }
}