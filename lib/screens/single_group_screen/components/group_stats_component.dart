import 'package:flutter/material.dart';

import '../../../constants.dart';

class GroupStatsComponent extends StatelessWidget {
  const GroupStatsComponent({
    Key key,
    @required this.postCount,
    @required this.followers,
  }) : super(key: key);

  final int postCount;
  final List<dynamic> followers;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              (postCount==null)?"0":postCount.toString().trim(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
            Text(
              "POSTS",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
              ),
            ),

          ],
        ),
        SizedBox(
          width: kDefaultPadding*5,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              (followers==null)?"0":followers.length.toString().trim(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
            Text(
              "MEMBERS",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}