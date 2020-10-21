import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/single_user_screen/single_user_screen.dart';


class ProfileScreen extends StatelessWidget {
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SingleUserScreen(_user.uid, _user.displayName);
  }
}
