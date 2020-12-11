import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/create_class_post_screen/create_class_post_screen.dart';

class SingleClassScreen extends StatelessWidget {
  final DocumentSnapshot classRoom;

  const SingleClassScreen(this.classRoom);

  @override
  Widget build(BuildContext context) {
    final _uid = FirebaseAuth.instance.currentUser.uid;
    final _classinfo = classRoom.data();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _classinfo["name"],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: kTextColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(
                "You are invited to join the classroom using code : ${_classinfo["classId"]} on $kAppName.",
                subject: "Invitation to join Friendzit classroom",
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (_) {
              return [
                PopupMenuItem(
                  child: Text("Edit Info"),
                ),
                PopupMenuItem(
                  child: Text("Students"),
                ),
              ];
            },
            child: Icon(Icons.more_vert),
            offset: Offset(
              0.0,
              50.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kDefaultPadding),
            ),
          ),
          SizedBox(
            width: kDefaultPadding,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (_)=>CreateClassPostScreen(classRoom.id)));
        },
        child: Icon(Icons.edit_outlined),
      ),
    );
  }
}
