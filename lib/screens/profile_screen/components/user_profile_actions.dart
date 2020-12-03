
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/chat_screen/chat_screen.dart';
import 'package:social_media/services/firestore_service.dart';

import '../../../constants.dart';

class UserProfileActions extends StatelessWidget {
  const UserProfileActions({
    Key key,
    @required this.data,
    @required User current,
    @required this.id,
  }) : _current = current, super(key: key);

  final Map<String, dynamic> data;
  final User _current;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        if ((data["friends"]==null || data["friends"][_current.uid]==null || data["friends"][_current.uid]==2)&& id != _current.uid)
          FlatButton.icon(
            onPressed: () async {
              await FirestoreService.sendFriendRequest(id);
            },
            icon: Icon(
              Icons.person_add_alt_1_rounded,
              color: kWhite,
            ),
            label: Text(
              "Send Request",
              style: TextStyle(
                color: kWhite,
                fontSize: 14.0,
              ),
            ),
            color: kPrimaryColor,
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(kDefaultPadding)),
          ),
        if ((data["friends"]!=null && data["friends"][_current.uid]!=null && data["friends"][_current.uid]==1)&& id != _current.uid)
          FlatButton.icon(
            onPressed: null,
            icon: Icon(
              Icons.person_add_alt_1_rounded,
              color: kTextColor,
            ),
            label: Text(
              "Request sent",
              style: TextStyle(
                color: kTextColor,
                fontSize: 14.0,
              ),
            ),
            color: kGrey,
            disabledColor: kGrey,
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(kDefaultPadding)),
          ),

        if ((data["friends"]!=null && data["friends"][_current.uid]!=null && data["friends"][_current.uid]==3)&& id != _current.uid)
          FlatButton.icon(
            onPressed: () async {
              await FirestoreService.rejectFriendRequest(id);
            },
            icon: Icon(
              Icons.person_remove_alt_1_rounded,
              color: kWhite,
            ),
            label: Text(
              "Unfriend",
              style: TextStyle(
                color: kWhite,
                fontSize: 14.0,
              ),
            ),
            color: kAccentColor,
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(kDefaultPadding)),
          ),
        if ((data["friends"]!=null && data["friends"][_current.uid]!=null && data["friends"][_current.uid]==3)&& id != _current.uid)
          FlatButton.icon(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (_)=>ChatScreen(data, id)));
            },
            icon: Icon(
              Icons.mail_outline,
              color: kWhite,
            ),
            label: Text(
              "Message",
              style: TextStyle(
                color: kWhite,
                fontSize: 14.0,
              ),
            ),
            color: kPrimaryColor,
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(kDefaultPadding)),
          ),

        if ((data["friends"]!=null && data["friends"][_current.uid]!=null && data["friends"][_current.uid]==0)&& id != _current.uid)
          FlatButton.icon(
            onPressed: () async {await FirestoreService.rejectFriendRequest(id);},
            icon: Icon(
                Icons.clear,
                color: kWhite
            ),
            label: Text(
              "Reject",
              style: TextStyle(
                color: kWhite,
                fontSize: 14.0,
              ),
            ),
            color: kAccentColor,
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(kDefaultPadding)),
          ),
        if ((data["friends"]!=null && data["friends"][_current.uid]!=null && data["friends"][_current.uid]==0)&& id != _current.uid)
          FlatButton.icon(
            onPressed: () async {await FirestoreService.acceptFriendRequest(id);},
            icon: Icon(
              Icons.check_outlined,
              color: kWhite,
            ),
            label: Text(
              "Accept",
              style: TextStyle(
                color: kWhite,
                fontSize: 14.0,
              ),
            ),
            color: kPrimaryColor,
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(kDefaultPadding)),
          ),

        if (id == _current.uid)
          FlatButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.edit_rounded,
              color: kWhite,
            ),
            label: Text(
              "Edit Profile",
              style: TextStyle(
                color: kWhite,
                fontSize: 14.0,
              ),
            ),
            color: kPrimaryColor,
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(kDefaultPadding)),
          ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceAround,
    );
  }
}
