
import 'package:flutter/material.dart';

import '../../../constants.dart';

class AdminGroupControllComponent extends StatelessWidget {
  const AdminGroupControllComponent({
    Key key,
    this.gid,
  }) : super(key: key);

  final gid;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FlatButton.icon(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          onPressed: () {},
          icon: Icon(Icons.edit_outlined),
          label: Text(
            "Edit Info",
            style: TextStyle(color: kTextColor),
          ),
          color: kWhite,
        ),
        FlatButton.icon(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          onPressed: () {},
          icon: Icon(Icons.delete,color: kWhite,),
          label: Text(
            "Delete",
            style: TextStyle(color: kWhite),
          ),
          color: kAccentColor,
        ),

      ],
    );
  }
}
