import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/components/empty_state_component.dart';
import 'package:social_media/components/post_widget.dart';

class SingleUserPost extends StatelessWidget {
  final String pId;

  const SingleUserPost(this.pId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("posts")
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
              child: EmptyStateComponent("Post Not Found."),
            );
          return SingleChildScrollView(
            child: PostWidget(
              post: data,
              key: Key(pId),
            ),
          );
        },
      ),
    );
  }
}
