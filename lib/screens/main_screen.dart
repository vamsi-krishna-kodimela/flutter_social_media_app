import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './auth_screens/login_screen.dart';
import './home_screen/home_screen.dart';

class MainScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return (_auth.currentUser == null)?LoginScreen():HomeScreen();
  }
}
