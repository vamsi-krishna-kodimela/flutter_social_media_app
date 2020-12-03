import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/group_posts_screen/components/posts_list_component.dart';
import 'package:social_media/screens/group_search_screen/group_search_screen.dart';
import '../create_group_screen/create_group_screen.dart';
import './components/groups_user_in_component.dart';

class GroupPostsScreen extends StatelessWidget {
  final _firestoreInstance = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildGroupAppBar(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateGroupScreen(),
            ),
          );
        },
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
        child: Container(
          color: kBGColor,
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreInstance
                .collection("groups")
                .where("members", arrayContains: _uid)
                .snapshots(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              final data = snapshot.data;
              if(! snapshot.hasData || data.size==0)
                return Center(child: Text("No Groups Found for you."));
              final _groups = data.docs.map((e) => e.id).toList();
              return Column(
                children: [
                  GroupsUserInComponent(),
                  Expanded(child: PostsListComponent(groups:_groups)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildGroupAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        "Groups",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: kTextColor,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search_rounded,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => GroupSearchScreen()),
            );
          },
        ),
      ],
      elevation: 0.0,
    );
  }
}
