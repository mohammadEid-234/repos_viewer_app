
import 'package:flutter/material.dart';
import 'package:github_reps/features/home/view/home_screen.dart';



void main() {
  runApp(ReposApp());
}

class ReposApp extends StatelessWidget {
  const ReposApp({super.key});

  //the root screen for the app

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      color: Colors.white,
      home: HomePage(),
      debugShowCheckedModeBanner: false, //hide debug banner
    );
  }
}


