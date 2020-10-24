import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media/constants.dart';
import 'components/group_description_component.dart';
import 'components/group_info_component.dart';
import 'components/group_tab_option_component.dart';

class SingleGroupScreen extends StatefulWidget {
  final String gid;
  final Map<String, dynamic> gData;

  SingleGroupScreen(this.gid, this.gData);

  @override
  _SingleGroupScreenState createState() => _SingleGroupScreenState();
}

class _SingleGroupScreenState extends State<SingleGroupScreen> {
  final uid = FirebaseAuth.instance.currentUser.uid;
  int option = 0;

  void optionChanger(val) {
    setState(() {
      option = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> members = widget.gData["members"];
    print(members);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: Column(
        children: [
          GroupInfoComponent(gData: widget.gData, uid: uid, gid: widget.gid),
          SizedBox(
            height: kDefaultPadding,
          ),
          Container(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GroupTabOptionComponent(
                  title: "About",
                  currentState: option,
                  setOption: optionChanger,
                  option: 0,
                ),
                GroupTabOptionComponent(
                  title: "Posts",
                  currentState: option,
                  setOption: optionChanger,
                  option: 1,
                ),
                GroupTabOptionComponent(
                  title: "Members",
                  currentState: option,
                  setOption: optionChanger,
                  option: 2,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (ctx, i) {
                final _firestore = FirebaseFirestore.instance
                    .collection("users")
                    .doc(members[i]);
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
                    return ListTile(title: Text(_userinfo["name"]),);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
