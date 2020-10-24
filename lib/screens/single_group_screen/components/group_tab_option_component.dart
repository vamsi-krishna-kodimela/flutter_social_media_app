
import 'package:flutter/material.dart';

import '../../../constants.dart';

class GroupTabOptionComponent extends StatelessWidget {


  final title;
  final currentState;
  final Function setOption;
  final int option;

  const GroupTabOptionComponent({Key key, this.title, this.currentState, this.setOption,this.option}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setOption(option),
      child: Container(
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: (option == currentState) ? kAccentColor : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: (option == currentState) ?Colors.black : Colors.black54,
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}
