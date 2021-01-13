import 'package:flutter/material.dart';
import 'package:social_media/screens/pages_screen/components/following_pages_component.dart';
import 'package:social_media/screens/pages_screen/components/page_posts_home.dart';
import '../create_page_screen/create_page_screen.dart';
import '../pages_search_screen/group_search_screen.dart';
import './components/created_pages_component.dart';
import '../../components/top_bar_option.dart';

import '../../constants.dart';

class PagesScreen extends StatefulWidget {
  @override
  _PagesScreenState createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> {
  int currentOption = 0;

  void changeOption(val) {
    setState(() {
      currentOption = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPageOptions(),
          Expanded(
            child: _widgetRetriver(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => CreatePageScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Container _buildPageOptions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: kDefaultPadding),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TopBarOption(
              isActive: currentOption == 0,
              option: "Posts",
              onPress: changeOption,
              optionNum: 0,
            ),
            TopBarOption(
              isActive: currentOption == 1,
              option: "Following",
              onPress: changeOption,
              optionNum: 1,
            ),
            TopBarOption(
              isActive: currentOption == 2,
              option: "My Pages",
              onPress: changeOption,
              optionNum: 2,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "Pages",
        style: TextStyle(fontWeight: FontWeight.w600, color: kTextColor),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => PagesSearchScreen()));
          },
        ),
      ],
      elevation: 0.0,
    );
  }

  Widget _widgetRetriver() {
    switch (currentOption) {
      case 1:
        return FollowingPagesComponent();
      case 2:
        return CreatedPagesComponent();
      case 0:
        return PagePostsScreen();
      default:
        return Center(
          child: Text("Something went wrong."),
        );
    }
  }
}
