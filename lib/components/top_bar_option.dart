import 'package:flutter/material.dart';

import '../constants.dart';

class TopBarOption extends StatelessWidget {
  final String option;
  final bool isActive;
  final Function onPress;
  final int optionNum;

  const TopBarOption({
    this.option,
    this.isActive,
    this.onPress,
    this.optionNum,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPress(optionNum);
      },
      child: Container(
        padding: EdgeInsets.only(left: kDefaultPadding, right: kDefaultPadding,bottom: kDefaultPadding/2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? kAccentColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isActive ? kPrimaryColor : kTextColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
