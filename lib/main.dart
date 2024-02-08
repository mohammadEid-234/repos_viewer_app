
import 'package:flutter/material.dart';
import 'package:github_reps/Pages/homeScreen.dart';



void main() {
  runApp(_RootWidget());
}

class _RootWidget extends StatelessWidget {
  //the root screen for the app

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      color: Colors.white,
      home: HomePage(),
      debugShowCheckedModeBanner: false, //hide debug banner
    );
  }
}


