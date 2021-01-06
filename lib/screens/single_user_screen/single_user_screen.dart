import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import '../profile_screen/components/user_feed.dart';

class SingleUserScreen extends StatelessWidget {
  final String uid;

  const SingleUserScreen(this.uid);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
      ),
      body: Container(
        width: _size.width,
        child: UserFeed(uid),
      ),
    );
  }
}
