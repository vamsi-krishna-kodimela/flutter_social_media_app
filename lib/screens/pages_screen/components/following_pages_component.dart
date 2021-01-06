import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/single_page_screen/single_page_screen.dart';

class FollowingPagesComponent extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("pages")
          .where("followers", arrayContains: _uid)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData)
          return Center(child: Text("No Pages Following."));
        List<DocumentSnapshot> _data = snapshot.data.docs;
        if (_data.length == 0)
          return Center(child: Text("No Pages Following."));
        return ListView.builder(
            padding: EdgeInsets.all(kDefaultPadding),
            itemCount: _data.length,
            itemBuilder: (ctx, i) {
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SinglePageScreen(
                          pageId: _data[i].id
                        ),
                      ),
                    );
                  },
                  title: Text(
                    _data[i].data()["name"],
                    style: TextStyle(
                        color: kTextColor, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "${_data[i].data()["description"]}",
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(kDefaultPadding),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: FancyShimmerImage(
                        imageUrl: _data[i].data()["pic"],
                        boxFit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}
