
import 'package:flutter/material.dart';

import '../../../constants.dart';

class CreateGroupButton extends StatelessWidget {
  final Function createGroup;

  const CreateGroupButton({Key key, this.createGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        createGroup();
      },
      child: InkWell(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 20.0,
          ),
          color: kAccentColor,
          width: double.infinity,
          child: Center(
            child: Text(
              "Create",
              style: TextStyle(
                color: kWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
