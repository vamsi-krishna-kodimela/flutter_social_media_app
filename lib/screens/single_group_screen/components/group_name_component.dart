import 'package:flutter/material.dart';

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
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}