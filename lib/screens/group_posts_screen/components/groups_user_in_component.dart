import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'group_tile_component.dart';

class GroupsUserInComponent extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100.0,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("groups").snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Shimmer.fromColors(
                child: Container(
                  height: 100.0,
                  color: Colors.black,
                ),
                baseColor: Colors.grey[300],
                highlightColor: Colors.grey[100]);

          List<QueryDocumentSnapshot> groups = snapshot.data.docs;
          if (groups.length == 0) return Container();
          return ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 20.0,
            ),
            scrollDirection: Axis.horizontal,
            itemBuilder: (ctx, i) {
              var data = groups[i].data();
              return GroupTileComponent(gid: groups[i].id, data: data,key: Key(groups[i].id),);
            },
            itemCount: groups.length,
          );
        },
      ),
    );
  }
}
