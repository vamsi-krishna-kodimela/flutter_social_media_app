import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/launch_screen.dart';
import './home_screen/home_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return (_auth.currentUser == null)?LaunchScreen():HomeScreen();
  }
}
