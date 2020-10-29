import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/single_user_screen/single_user_screen.dart';

class GroupMembersComponent extends StatelessWidget {
  GroupMembersComponent({
    Key key,
    @required this.members,
    @required this.admins,
    @required this.gid,
  }) : super(key: key);

  final List members;
  final List admins;
  final String gid;
  final String uid = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    members.removeWhere((element) => element==uid);
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (ctx, i) {
        final _firestore =
            FirebaseFirestore.instance.collection("users").doc(members[i]);
        return StreamBuilder<DocumentSnapshot>(
          stream: _firestore.snapshots(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Shimmer.fromColors(
                child: ListTile(
                  title: Text("Loading..."),
                ),
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100],
              );
            final _userinfo = snapshot.data.data();
            if (!admins.contains(uid))
              return Card(
                key: Key(members[i]),
                elevation: 0.0,
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            SingleUserScreen(members[i], _userinfo["name"]),
                      ),
                    );
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      8.0,
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: FancyShimmerImage(
                        imageUrl: _userinfo["photoUrl"],
                        boxFit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    _userinfo["name"],
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle:
                      Text(admins.contains(members[i]) ? "Admin" : "Member"),
                ),
              );

            return Dismissible(
              direction: DismissDirection.endToStart,
              key: Key(members[i]),
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: kDefaultPadding),
                color: kAccentColor,
                child: Icon(
                  Icons.delete,
                  color: kWhite,
                ),
              ),
              child: Card(
                elevation: 0.0,
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            SingleUserScreen(members[i], _userinfo["name"]),
                      ),
                    );
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      8.0,
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: FancyShimmerImage(
                        imageUrl: _userinfo["photoUrl"],
                        boxFit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    _userinfo["name"],
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle:
                      Text(admins.contains(members[i]) ? "Admin" : "Member"),
                  trailing: IconButton(
                    onPressed: () async {
                      (admins.contains(members[i]))
                          ? await firestore
                              .collection("groups")
                              .doc(gid)
                              .update({
                              "admins": FieldValue.arrayRemove([members[i]]),
                            })
                          : await firestore
                              .collection("groups")
                              .doc(gid)
                              .update({
                              "admins": FieldValue.arrayUnion([uid]),
                            });
                    },
                    icon: Icon(
                      Icons.admin_panel_settings,
                      color:
                          (admins.contains(members[i])) ? kAccentColor : kGreen,
                    ),
                  ),
                ),
              ),
              onDismissed: (dir) async {
                await _firestore.collection("groups").doc(gid).update({
                  "admins": FieldValue.arrayRemove([uid]),
                  "members": FieldValue.arrayRemove([uid]),
                });
              },
            );
          },
        );
      },
    );
  }
}
