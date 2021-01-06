import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
            child: PostWidget(
              post: pId,
              key: Key(pId),
            ),
          );
        },
      ),
    );
  }
}
