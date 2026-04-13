import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/views/SplashScreenUI.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: '',
    anonKey: '',
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
      home: Splashscreenui(),
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)),
    );
  }
}