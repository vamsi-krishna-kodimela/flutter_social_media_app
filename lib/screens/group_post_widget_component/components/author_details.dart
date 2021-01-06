import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../single_user_screen/single_user_screen.dart';

import '../../../constants.dart';

class AuthorDetails extends StatelessWidget {
  const AuthorDetails({
    Key key,
    @required Size size,
    @required Map<String, dynamic> userInfo,
    @required this.postedOnString,
    @required this.uid,
    @required this.postId,
    @required this.gid,
    @required this.function,
  })  : _size = size,
        _userInfo = userInfo,
        super(key: key);

  final Size _size;
  final Map<String, dynamic> _userInfo;
  final String postedOnString;
  final String uid;
  final String postId;
  final Function function;
  final String gid;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (uid != FirebaseAuth.instance.currentUser.uid) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SingleUserScreen(uid),
            ),
          );
        }
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
      subtitle: Text(
        postedOnString,
        style: TextStyle(color: kGrey),
      ),
      trailing: (uid == FirebaseAuth.instance.currentUser.uid)
          ? IconButton(
        icon: Icon(
          Icons.delete_outline_outlined,
          color: kAccentColor,
        ),
        onPressed: () async {
          await showDialog(
            builder: (cx) {
              return AlertDialog(
                title: Text(
                  "Are you Sure to delete?",
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
                          .collection("group_posts")
                          .doc(postId)
                          .delete();
                      function();
                      Navigator.of(cx).pop();
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
                      Navigator.of(cx).pop();
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
    );
  }
}