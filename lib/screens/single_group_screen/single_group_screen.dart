import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
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
  int option = 0;
  void optionChanger(val) {
    setState(() {
      option = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> members = widget.gData["members"];
    // members.removeWhere((element) => element==uid);
    final List<dynamic> admins = widget.gData["admins"];
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
          SizedBox(height: kDefaultPadding,),
          Expanded(
            child: GroupMembersComponent(members: members, admins: admins),
          ),
        ],
      ),
    );
  }
}
