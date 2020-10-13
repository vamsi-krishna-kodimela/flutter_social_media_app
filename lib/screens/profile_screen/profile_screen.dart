import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'components/user_feed.dart';

class ProfileScreen extends StatelessWidget {
  final String uid = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Container(
      width: _size.width,
      child: UserFeed(uid),
    );
  }
}
