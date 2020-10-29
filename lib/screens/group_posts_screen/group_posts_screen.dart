import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/group_posts_screen/components/posts_list_component.dart';
import '../create_group_screen/create_group_screen.dart';
import './components/groups_user_in_component.dart';

class GroupPostsScreen extends StatefulWidget {
  @override
  _GroupPostsScreenState createState() => _GroupPostsScreenState();
}

class _GroupPostsScreenState extends State<GroupPostsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: _buildGroupAppBar(),
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
          child: Column(
            children: [
              GroupsUserInComponent(),
              Expanded(
                child: PostsListComponent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildGroupAppBar() {
    return AppBar(
      title: Text(
        "Groups",
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search_rounded,
            color: kWhite,
          ),
          onPressed: () {},
        ),
      ],
      elevation: 0.0,
    );
  }
}
