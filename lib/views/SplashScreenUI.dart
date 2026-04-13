import 'package:flutter/material.dart';

class Splashscreenui extends StatefulWidget {
  const Splashscreenui({super.key});

  @override
  State<Splashscreenui> createState() => _SplashscreenuiState();
}

class _SplashscreenuiState extends State<Splashscreenui> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}