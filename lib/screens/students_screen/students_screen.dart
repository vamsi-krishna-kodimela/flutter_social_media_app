import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media/screens/single_user_screen/single_user_screen.dart';
import '../../constants.dart';

class StudentsScreen extends StatelessWidget {
  final String classId;

  const StudentsScreen(this.classId);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final _firestore = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Students",
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("class_rooms").doc(classId).snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          final _data = snapshot.data.data();
          final _teacher = _data["createdBy"];
          List<dynamic> _students = _data["students"];
          _students.remove(_teacher);
          if (_students.length == 0)
            return Center(child: Text("No Students Found."));
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (__, i) {
                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection("users").doc(_students[i]).get(),
                  builder: (ctx, snapshot) {
                    if (snapshot.data == null) {
                      return ListTile(
                        leading: Container(
                          width: _size.width * 0.1,
                          height: _size.width * 0.1,
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(_size.width * 0.1),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300],
                              highlightColor: Colors.grey[100],
                              child: Container(
                                width: _size.width * 0.1,
                                height: _size.width * 0.1,
                                color: kAccentColor,
                              ),
                            ),
                          ),
                        ),
                        title: Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.grey[100],
                          child: Container(
                            width: _size.width * 0.2,
                            height: 16.0,
                            color: kAccentColor,
                          ),
                        ),

                      );
                    }
                    final _userInfo = snapshot.data.data();
                    return _AuthorDetails(
                      size: _size,
                      userInfo: _userInfo,
                      uid: snapshot.data.id,
                      postId: classId,
                      teacher: _teacher,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AuthorDetails extends StatelessWidget {
  const _AuthorDetails({
    Key key,
    @required Size size,
    @required Map<String, dynamic> userInfo,
    @required this.uid,
    @required this.postId,
    @required this.teacher,
  })  : _size = size,
        _userInfo = userInfo,
        super(key: key);

  final Size _size;
  final Map<String, dynamic> _userInfo;
  final String uid;
  final String postId;
  final String teacher;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SingleUserScreen(uid, _userInfo["name"]),
              ),
            );

        },
        contentPadding: EdgeInsets.all(0.0),
        leading: Container(
          width: _size.width * 0.1,
          height: _size.width * 0.1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kDefaultPadding),
            child: FancyShimmerImage(
              imageUrl: _userInfo["photoUrl"],
              boxFit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          _userInfo["name"],
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        trailing: (teacher == FirebaseAuth.instance.currentUser.uid)
            ? IconButton(
          icon: Icon(
            Icons.cancel_outlined,
            color: kAccentColor,
          ),
          onPressed: () async {
            await showDialog(
              builder: (ctx) {
                return AlertDialog(
                  title: Text(
                    "Are you Sure to remove this student?",
                    style: TextStyle(
                      color: kTextColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    FlatButton(
                      color: kPrimaryColor.withAlpha(20),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection("class_rooms")
                            .doc(postId).update({
                          "students":FieldValue.arrayRemove([uid]),
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FlatButton(
                      color: kAccentColor,
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        "No",
                        style: TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
              context: context,
            );
          },
        )
            : Text(""),
      ),
    );
  }
}
