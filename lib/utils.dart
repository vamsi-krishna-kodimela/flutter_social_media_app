import 'package:flutter/material.dart';
import 'package:social_media/screens/single_group_post/single_group_post.dart';
import 'package:social_media/screens/single_page_post/single_page_post.dart';
import 'package:social_media/screens/single_user_screen/single_user_screen.dart';

import 'screens/single_class_post/single_class_post.dart';

List<String> keyWordGenerator(String key) {
  final List<String> keys = [];

  for (var i = 1; i <= key.length; i++) {
    for (var j = 0; j < key.length; j++) {
      if (j + i > key.length) break;
      var symb = key.substring(j, j + i).toLowerCase();
      if (!keys.contains(symb)) keys.add(symb);
    }
  }

  return keys;
}

void notificationNavigator(
    {String type, BuildContext ctx, String id, String name = ""}) {
  Function _nav;
  switch (type) {
    case "PAGE_POST":
      _nav = (_) => SinglePagePost(id);
      break;
    case "GROUP_POST":
      _nav = (_) => SingleGroupPost(id);
      break;
    case "CLASS_POST":
      _nav = (_) => SingleClassPost(id);
      break;
    case "ACCEPTED":
      _nav = (_) => SingleUserScreen(id);
      break;
    case "RECEIVED":
      _nav = (_) => SingleUserScreen(id);
      break;
    default:
      print("Some thing went wrong");
      return;
  }
  Navigator.of(ctx).push(MaterialPageRoute(builder: _nav));
}

colorGenerator(int color) {
  if (color == null) color = 0;
  if (color < 0 || color > 6) color = 0;
  final colors = [
    Color(0xFF168400),
    Color(0xFF1a0363),
    Color(0xFF0d8491),
    Color(0xFF890c1b),
    Color(0xFF310891),
    Color(0xFFb25c00),
    Color(0xFF930301)
  ];

  return colors[color];
}
