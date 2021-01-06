import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/utils.dart';

class NotificationTile extends StatelessWidget {
  final QueryDocumentSnapshot data;
  final _firestore = FirebaseFirestore.instance;

  NotificationTile({@required Key key, @required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _info = data.data();
    final DateTime postedOn = _info["createdOn"].toDate();
    final Duration _dur = DateTime.now().difference(postedOn);
    String postedOnString;
    if (_dur.inSeconds < 10) {
      postedOnString = "JUST";
    } else if (_dur.inHours < 24) {
      postedOnString = "TODAY";
    } else if (_dur.inHours < 48) {
      postedOnString = "YESTERDAY";
    } else if (_dur.inDays < 20) {
      postedOnString = "${_dur.inDays} days ago";
    } else {
      postedOnString = "${DateFormat("dd MMM, yyyy").format(postedOn)}";
    }

    return Container(
      child: Card(
        elevation: 0.0,
        margin: EdgeInsets.symmetric(
          vertical: 2.0,
        ),
        child: ListTile(
          onTap: () {
            data.reference.delete();
            notificationNavigator(
                type: _info["notificationType"].toString(), ctx: context, id: _info["id"],name : _info["name"],);
          },
          title: Text(
            _info["message"],
            style: TextStyle(
              color: kTextColor,
              fontSize: 18.0,
            ),
          ),
          trailing: (_info["photoUrl"] != null && _info["type"]==0)
              ? AspectRatio(
                  aspectRatio: 1.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(kDefaultPadding),
                    child: FancyShimmerImage(
                      imageUrl: _info["photoUrl"],
                      boxFit: BoxFit.cover,
                    ),
                  ))
              : null,
          subtitle: Text(
            "$postedOnString",
            style: TextStyle(
              color: kGrey,
              fontSize: 14.0,
            ),
          ),
        ),
      ),
    );
  }
}
