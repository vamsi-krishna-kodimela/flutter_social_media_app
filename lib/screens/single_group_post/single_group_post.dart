import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/group_post_widget_component/group_post_widget_component.dart';

class SingleGroupPost extends StatelessWidget {
  final String pId;

  const SingleGroupPost(this.pId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
              child: Column(
                children: [
                  Image.asset("assets/empty_state.png",fit: BoxFit.fitWidth, width: MediaQuery.of(context).size.width*0.7,),
                  Text(
                    "POST NOT FOUND!",
                    style: TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                ],
              ),
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
