
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/page_post_list/components/page_post_widget.dart';


class PagePostListScreen extends StatelessWidget {

  final String pid;

  const PagePostListScreen(this.pid);


  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("page_posts").where("page",isEqualTo: pid).snapshots(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        final _data = snapshot.data;
        if(_data.size==0)
          return Center(child: Text("No Posts found"),);
        return ListView.builder(
          itemCount: _data.size,
          itemBuilder: (_, i) {
            return PagePostWidget(key: Key(_data.docs[i].id),post: _data.docs[i],);
          },
        );
      },
    );
  }
}




