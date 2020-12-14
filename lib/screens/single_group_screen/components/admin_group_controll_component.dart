
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/create_group_screen/edit_group_screen.dart';

import '../../../constants.dart';

class AdminGroupControllComponent extends StatelessWidget {
  const AdminGroupControllComponent({
    Key key,
    this.gid,
    this.gData,

  }) : super(key: key);

  final gid;
  final gData;


  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FlatButton.icon(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_)=>EditGroupScreen(groupData: gData,gid: gid,)));
          },
          icon: Icon(Icons.edit_outlined,color: kWhite,),
          label: Text(
            "Edit Info",
            style: TextStyle(color: kWhite),
          ),
          color: kPrimaryColor,
        ),
        FlatButton.icon(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          onPressed: () async{
            await _firestore.collection("groups").doc(gid).delete();
            Navigator.of(context).pop();
          },
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
