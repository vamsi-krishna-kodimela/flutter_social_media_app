
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'admin_group_controll_component.dart';
import 'group_name_component.dart';
import 'group_pic_component.dart';
import 'group_stats_component.dart';

class GroupInfoComponent extends StatelessWidget {
  const GroupInfoComponent({
    Key key,
    @required this.gData,
    @required this.uid,
    @required this.gid,
  }) : super(key: key);


  final Map<String, dynamic> gData;
  final String uid;
  final String gid;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> admins = gData["admins"];
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)),
      child: Container(
        color: kPrimaryColor,
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
            if (admins.contains(uid))
              AdminGroupControllComponent(gid: gid),
            SizedBox(
              height: kDefaultPadding * 3,
            ),
          ],
        ),
      ),
    );
  }
}
