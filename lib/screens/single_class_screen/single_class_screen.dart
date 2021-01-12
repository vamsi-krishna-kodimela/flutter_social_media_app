import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/create_class_post_screen/create_class_post_screen.dart';
import 'package:social_media/screens/create_class_screen/edit_class_screen.dart';
import 'package:social_media/screens/single_class_screen/components/class_post_list.dart';
import 'package:social_media/screens/students_screen/students_screen.dart';

class SingleClassScreen extends StatefulWidget {
  final DocumentSnapshot classRoom;

  const SingleClassScreen(this.classRoom);

  @override
  _SingleClassScreenState createState() => _SingleClassScreenState();
}

class _SingleClassScreenState extends State<SingleClassScreen> {
  final _uid = FirebaseAuth.instance.currentUser.uid;
  @override
  Widget build(BuildContext context) {

    final _classinfo = widget.classRoom.data();
    return Scaffold(
      appBar: _buildAppBar(_classinfo),
      floatingActionButton: (_uid == _classinfo["createdBy"]) ?FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CreateClassPostScreen(widget.classRoom.id)));
        },
        child: Icon(Icons.edit_outlined),
      ):null,
      body: ClassPostList(widget.classRoom.id),
    );
  }

  AppBar _buildAppBar(Map<String, dynamic> _classinfo) {
    return AppBar(
      title: Text(
        _classinfo["name"],
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: kTextColor,
        ),
      ),
      actions: [
        PopupMenuButton(
          itemBuilder: (_) {
            return [
              if(_uid == _classinfo["createdBy"]) PopupMenuItem(
                child: Text("Edit Info"),
                value: 0,
              ),
              PopupMenuItem(
                child: Text("Students"),
                value: 1,
              ),
              PopupMenuItem(
                child: Text("Share"),
                value: 2,
              ),
            ];
          },
          onSelected: (val) {
            switch (val) {
              case 0:
                Navigator.of(context).push(MaterialPageRoute(builder: (_)=>EditClassScreen(widget.classRoom)));
                break;
              case 1:
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StudentsScreen(widget.classRoom.id),
                  ),
                );
                break;
              case 2:
                Share.share(
                  "You are invited to join the classroom using code : ${_classinfo["classId"]} on $kAppName.",
                  subject: "Invitation to join Friendzit classroom",
                );
                break;
            }
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
    );
  }
}
