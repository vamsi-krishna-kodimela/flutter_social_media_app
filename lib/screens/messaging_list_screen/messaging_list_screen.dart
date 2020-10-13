import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media/screens/chat_screen/chat_screen.dart';

import '../../constants.dart';

class MessagingListScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("chatRooms")
          .orderBy("lastPostedOn", descending: true)
          .where("users", arrayContains: uid)
          .where("status", isEqualTo: 1)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(),
          );

        if (snapshot.data == null)
          return Center(
            child: Text("Start making friends to chat..."),
          );
        List<QueryDocumentSnapshot> _chats = snapshot.data.docs;
        return ListView.builder(
          padding: EdgeInsets.only(
            top: kDefaultPadding,
            left: kDefaultPadding,
            right: kDefaultPadding,
          ),
          itemCount: _chats.length,
          itemBuilder: (_, i) {
            var chat = _chats[i].data();
            List<dynamic> friends = chat["users"];
            String postedOnString;
            final DateTime postedOn = chat["lastPostedOn"].toDate();
            final Duration _dur = DateTime.now().difference(postedOn);
            if (_dur.inSeconds < 2) {
              postedOnString = "Just Now";
            } else if (_dur.inSeconds < 60) {
              postedOnString = "${_dur.inSeconds} seconds ago";
            } else if (_dur.inMinutes < 60) {
              postedOnString = "${_dur.inMinutes} minutes ago";
            } else if (_dur.inHours < 24) {
              postedOnString = "Posted ${_dur.inHours} hours ago";
            } else {
              postedOnString =
                  "Posted on ${DateFormat("dd MMM, yyyy").format(postedOn)}";
            }
            friends.removeWhere((element) => element == uid);
            return Card(
              child: FutureBuilder<DocumentSnapshot>(
                future: chat["userRef"][friends[0]].get(),
                builder: (ctx, snapshot) {
                  if (snapshot.data == null) {
                    return ListTile(
                      leading: Container(
                        width: _size.width * 0.1,
                        height: _size.width * 0.1,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(_size.width * 0.1),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              width: _size.width * 0.1,
                              height: _size.width * 0.1,
                              color: kAccentColor,
                            ),
                          ),
                        ),
                      ),
                      title: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          width: _size.width * 0.2,
                          height: 16.0,
                          color: kAccentColor,
                        ),
                      ),
                      subtitle: Text(
                        postedOnString,
                        style: TextStyle(color: kGrey),
                      ),
                    );
                  }
                  final _userInfo = snapshot.data.data();
                  return _AuthorDetails(
                    size: _size,
                    userInfo: _userInfo,
                    postedOnString: postedOnString,
                    uid: snapshot.data.id,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _AuthorDetails extends StatelessWidget {
  const _AuthorDetails({
    Key key,
    @required Size size,
    @required Map<String, dynamic> userInfo,
    @required this.postedOnString,
    @required this.uid,
  })  : _size = size,
        _userInfo = userInfo,
        super(key: key);

  final Size _size;
  final Map<String, dynamic> _userInfo;
  final String postedOnString;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(_userInfo, uid),
          ),
        );
      },
      leading: Container(
        width: _size.width * 0.1,
        height: _size.width * 0.1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kDefaultPadding),
          child: FancyShimmerImage(
            imageUrl: _userInfo["photoUrl"],
            boxFit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        _userInfo["name"],
        style: TextStyle(
          color: kTextColor,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        postedOnString,
        style: TextStyle(color: kGrey),
      ),
    );
  }
}
