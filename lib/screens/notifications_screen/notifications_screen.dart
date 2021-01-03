import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import 'components/notification_tile.dart';

class NotificationsScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

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
        stream: _firestore.collection("notifications").snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          final data = snapshot.data;
          if (data.size == 0)
            return Center(
              child: Text("You are all done."),
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
