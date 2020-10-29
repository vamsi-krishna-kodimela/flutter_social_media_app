import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/create_group_post_screen/create_group_post_screen.dart';
import 'package:social_media/screens/group_posts_screen/components/posts_list_component.dart';
import 'package:social_media/screens/single_group_screen/components/group_description_component.dart';
import 'components/group_info_component.dart';
import 'components/group_members_component.dart';
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
  List<dynamic> members = [];
  List<dynamic> admins = [];
  int option = 0;
  final _firestore = FirebaseFirestore.instance;

  void optionChanger(val) {
    setState(() {
      option = val;
    });
  }

  @override
  void initState() {
    super.initState();
    members = widget.gData["members"];
    admins = widget.gData["admins"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("groups").doc(widget.gid).snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          var _data = snapshot.data;
          var gData = _data.data();

          return Column(
            children: [
              GroupInfoComponent(gData: gData, uid: uid, gid: widget.gid),
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
              SizedBox(
                height: kDefaultPadding,
              ),
              Expanded(
                child: widgetSwitch(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateGroupPostScreen(widget.gid),
            ),
          );
        },
        child: Icon(Icons.edit),
      ),

    );
  }

  widgetSwitch() {
    switch (option) {
      case 1:
        return PostsListComponent(widget.gid);
      case 2:
        return GroupMembersComponent(
          members: members,
          admins: admins,
          gid: widget.gid,
        );
      default:
        return GroupDescriptionComponent(
            description: widget.gData["description"]);
    }
  }
}
