import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'admin_group_controll_component.dart';
import 'group_name_component.dart';
import 'group_pic_component.dart';
import 'group_stats_component.dart';

class GroupInfoComponent extends StatelessWidget {
  GroupInfoComponent({
    Key key,
    @required this.gData,
    @required this.uid,
    @required this.gid,
  }) : super(key: key);

  final Map<String, dynamic> gData;
  final String uid;
  final String gid;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // if(gData ==null)
    //   Navigator.of(context).pop();
    if(gData == null)
      return Center(child: Text("Group Deleted"));
    final List<dynamic> admins = gData["admins"];

    final List<dynamic> members = gData["members"];

    return Container(
      color: kWhite,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          GroupPicComponent(picUrl: gData["pic"]),
          SizedBox(height: kDefaultPadding),
          GroupNameComponent(gName: gData["name"]),
          SizedBox(height: kDefaultPadding * 2),
          GroupStatsComponent(
            postCount: gData["posts"],
            followers: gData["members"],
          ),


          SizedBox(height: kDefaultPadding),
          if (admins.contains(uid)) AdminGroupControllComponent(gid: gid,gData: gData,ctx: context,),
          if (members.contains(uid) &&
              (!admins.contains(uid) || admins.length > 1))
            FlatButton.icon(
              onPressed: () async {
                await _firestore.collection("groups").doc(gid).update({
                  "admins": FieldValue.arrayRemove([uid]),
                  "members": FieldValue.arrayRemove([uid]),
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              label: Text(
                "Leave Group",
                style: TextStyle(color: kAccentColor),
              ),
              icon: Icon(
                Icons.cancel_outlined,
                color: kAccentColor,
              ),
              color: Colors.white54,
            ),
          if (!members.contains(uid))
            FlatButton.icon(
              onPressed: () async {
               await  _firestore.collection("groups").doc(gid).update({
                 "members" : FieldValue.arrayUnion([uid]),
               });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              label: Text(
                "Join Group",
                style: TextStyle(color: kWhite),
              ),
              icon: Icon(
                Icons.add,
                color: kWhite,
              ),
              color: kGreen,
            ),
          SizedBox(
            height: kDefaultPadding * 3,
          ),
        ],
      ),
    );
  }
}
