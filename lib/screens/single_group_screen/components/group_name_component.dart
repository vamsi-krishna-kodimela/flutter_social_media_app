import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';

class GroupNameComponent extends StatelessWidget {
  const GroupNameComponent({
    Key key,
    @required this.gName,
  }) : super(key: key);

  final String gName;

  @override
  Widget build(BuildContext context) {
    return Text(
      gName.toString().trim(),
      style: TextStyle(
        color: kTextColor,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}