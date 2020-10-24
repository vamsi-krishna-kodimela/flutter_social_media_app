
import 'package:flutter/material.dart';

import '../../../constants.dart';

class GroupDescriptionComponent extends StatelessWidget {
  const GroupDescriptionComponent({
    Key key,
    @required this.description,
  }) : super(key: key);

  final String description;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(
          20.0,
        ),
        child: Text(
          description,
          style: TextStyle(
            color: kTextColor,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}
