import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media/components/empty_state_component.dart';
import 'package:social_media/screens/group_post_widget_component/group_post_widget_component.dart';

import '../../constants.dart';

class SingleGroupPost extends StatelessWidget {
  final String pId;

  const SingleGroupPost(this.pId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          kAppName,
          style: TextStyle(
            color: kTextColor,
            fontFamily: GoogleFonts.lobster().fontFamily,
            fontSize: 26.0,
          ),
        ),

      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("group_posts")
            .doc(pId)
            .snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          final data = snapshot.data;
          if (!data.exists)
            return Center(
              child: EmptyStateComponent("Post Not Found.")
            );
          return SingleChildScrollView(
            child: GroupPostWidgetComponent(
              post: data,
              key: Key(data.id),
              function: () {
                print("Hello World");
              },
            ),
          );
        },
      ),
    );
  }
}
