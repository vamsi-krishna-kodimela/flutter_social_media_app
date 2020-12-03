import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../page_post_list/components/page_post_widget.dart';

class PagePostsHome extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection("pages")
          .where("followers", arrayContains: _uid)
          .get(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(),
          );
        final _data = snapshot.data.docs;
        List<String> _pages = [];

        for(var j in _data){
          _pages.add(j.id);
          print("Hello");
        }
        if(_pages.length==0)
          return Center(child: Text("Follow pages to see their posts."),);
        return StreamBuilder(
          stream: _firestore.collection("page_posts").where("page",whereIn: _pages).snapshots(),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            final _data = snap.data;
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
      },
    );
  }
}
