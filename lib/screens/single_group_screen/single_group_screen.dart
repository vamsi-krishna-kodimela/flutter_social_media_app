import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:share/share.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/create_group_post_screen/create_group_post_screen.dart';
import 'package:social_media/screens/group_posts_screen/components/posts_list_component.dart';
import 'package:social_media/screens/single_group_screen/components/group_description_component.dart';
import 'components/group_info_component.dart';
import 'components/group_members_component.dart';
import 'components/group_tab_option_component.dart';

class SingleGroupScreen extends StatefulWidget {
  final String gid;

  SingleGroupScreen(this.gid);

  @override
  _SingleGroupScreenState createState() => _SingleGroupScreenState();
}

class _SingleGroupScreenState extends State<SingleGroupScreen> {
  final uid = FirebaseAuth.instance.currentUser.uid;

  int option = 0;
  final _firestore = FirebaseFirestore.instance;

  void optionChanger(val) {
    if (option != val)
      setState(() {
        option = val;
      });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("groups").doc(widget.gid).snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );

          var _data = snapshot.data;
          if(!_data.exists)

            return Scaffold(

              appBar: AppBar(
                elevation: 0.0,

              ),
              body: Center(
                child: Text("GROUP NOT FOUND."),
              ),
            );

          var gData = _data.data();
          if (gData == null) Navigator.of(context).pop();

          return _GroupScreen(
            key: Key(widget.gid),
            gid: widget.gid,
            gData: gData,
            option: option,
            optionChanger: optionChanger,
            uid: uid,
            members: gData["members"],
          );
        },
      );
  }
}

class _GroupScreen extends StatelessWidget {
  final gData;
  final uid;
  final gid;
  final option;
  final optionChanger;
  final members;

  const _GroupScreen(
      {Key key,
      this.gData,
      this.uid,
      this.gid,
      this.option,
      this.optionChanger,
      this.members})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: kWhite,
        actions: [
          IconButton(
            icon: Icon(FeatherIcons.share2),
            onPressed: () {
              Share.share("https://friendzit.in/group/$gid");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          GroupInfoComponent(gData: gData, uid: uid, gid: gid),
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
      ),
      floatingActionButton: (members.contains(uid))?FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateGroupPostScreen(gid),
            ),
          );
        },
        child: Icon(Icons.edit),
      ):null,
    );
  }

  widgetSwitch() {
    switch (option) {
      case 1:
        return PostsListComponent(gid: gid);
      case 2:
        return GroupMembersComponent(gid: gid);
      default:
        return GroupDescriptionComponent(description: gData["description"]);
    }
  }
}
