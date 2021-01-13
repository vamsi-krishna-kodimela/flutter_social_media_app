import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../../constants.dart';
import 'components/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notification",
          style: TextStyle(fontWeight: FontWeight.w600, color: kTextColor),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("notifications").where("recievers",arrayContains: _uid).orderBy("createdOn",descending: true).snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          final data = snapshot.data;
          if (data.size == 0)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FeatherIcons.bell,size: 40.0,),
                  SizedBox(height: kDefaultPadding,),
                  Text("You are all done for now.",style: TextStyle(color: kAccentColor,fontSize: 20.0),),
                ],
              ),
            );
          final _docs = data.docs;
          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (_, i) {
              return NotificationTile(key: Key(_docs[i].id), data: _docs[i]);
            },
          );
        },
      ),
    );
  }
}
