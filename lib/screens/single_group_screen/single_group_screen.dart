import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'components/group_info_component.dart';


class SingleGroupScreen extends StatelessWidget {
  final uid = FirebaseAuth.instance.currentUser.uid;

  final String gid;
  final Map<String, dynamic> gData;

  SingleGroupScreen(this.gid, this.gData);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
      ),
      body: Column(
        children: [
          GroupInfoComponent(gData: gData, uid: uid, gid: gid),

        ],
      ),
    );
  }
}
