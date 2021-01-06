import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media/providers/chats_provider.dart';
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
      .where("status",isEqualTo: 1)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(),
          );
          Provider.of<ChatsProvider>(context).clearChats();
        if (snapshot.data == null)
          return Center(
            child: Text("Start making friends to chat..."),
          );
        List<QueryDocumentSnapshot> _chats = snapshot.data.docs;
        if (_chats.length==0)
          return Center(
            child: Text("Start making friends to chat..."),
          );
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
            final String _message = (chat["lastMessage"] == null)
                ? ""
                : chat["lastMessage"]["message"];

            final DateTime postedOn = chat["lastPostedOn"].toDate();

            final Duration _dur = DateTime.now().difference(postedOn);
            if (_dur.inSeconds < 2) {
              postedOnString = "Just Now";
            } else if (_dur.inSeconds < 60) {
              postedOnString = "${_dur.inSeconds} secs";
            } else if (_dur.inMinutes < 60) {
              postedOnString = "${_dur.inMinutes} mins";
            } else if (_dur.inHours < 24) {
              postedOnString = "${_dur.inHours} hrs";
            } else {
              postedOnString = "${DateFormat("dd MMM, yyyy").format(postedOn)}";
            }
            friends.removeWhere((element) => element == uid);
            return Card(
              child: StreamBuilder<DocumentSnapshot>(
                stream: chat["userRef"][friends[0]].snapshots(),
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
                    message: _message,
                    key: Key(snapshot.data.id),
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
    this.message,
  })  : _size = size,
        _userInfo = userInfo,
        super(key: key);

  final Size _size;
  final Map<String, dynamic> _userInfo;
  final String postedOnString;
  final String message;
  final String uid;

  @override
  Widget build(BuildContext context) {
    Provider.of<ChatsProvider>(context, listen: false).clearChats();
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(_userInfo, uid),
          ),
        );
      },
      leading: Stack(
        children: [
          Container(
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
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 10.0,
              height: 10.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.0),
                color: (_userInfo["status"] == 1) ? kGreen : kAccentColor,
                border: Border.all(color: kWhite, width: 2.0),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        _userInfo["name"],
        style: TextStyle(
          color: kTextColor,
          fontWeight: FontWeight.normal,
          fontSize: 17,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: (message != null)
          ? Text(
            message,
            style: TextStyle(
              color: Color(0x99000000),
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          )
          : null,
      trailing: Text(
        postedOnString,
        style: TextStyle(
          color: kGrey,
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
