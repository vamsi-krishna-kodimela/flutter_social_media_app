import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import '../profile_screen/components/user_feed.dart';

class SingleUserScreen extends StatelessWidget {
  final String uid;
  final String name;

  const SingleUserScreen(this.uid,this.name);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        title: Text(name,style: TextStyle(color: kTextColor,fontWeight: FontWeight.w600),),
      ),
      body: Container(
        width: _size.width,
        child: UserFeed(uid),
      ),
    );
  }
}
