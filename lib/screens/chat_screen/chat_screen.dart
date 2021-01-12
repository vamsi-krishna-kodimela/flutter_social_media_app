import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants.dart';
import '../single_user_screen/single_user_screen.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> friend;

  final String frienId;

  const ChatScreen(this.friend, this.frienId);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String currentId = FirebaseAuth.instance.currentUser.uid;
  final TextEditingController messageController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  String _chatRoomId;

  _buildMessage(Map<String, dynamic> message, bool isMe) {
    final DateTime postedOn = message["postedOn"].toDate();
    final Duration _dur = DateTime.now().difference(postedOn);

    String postedOnString;
    if (_dur.inSeconds < 2) {
      postedOnString = "Just Now";
    } else if (_dur.inSeconds < 60) {
      postedOnString = "${_dur.inSeconds} secs ago";
    } else if (_dur.inMinutes < 60) {
      postedOnString = "${_dur.inMinutes} mins ago";
    } else if (_dur.inHours < 24) {
      postedOnString = "${_dur.inHours} hrs ago";
    } else {
      postedOnString = "${DateFormat("dd MMM, yyyy").format(postedOn)}";
    }

    final Container msg = Container(
      margin: isMe
          ? EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              left: 80.0,
            )
          : EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              right: 80.0,
            ),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: isMe ? Theme.of(context).primaryColor : kWhite,
        boxShadow: [
          BoxShadow(
            color: kGrey,
            blurRadius: 4.0,
            offset: Offset(0.0, 0.0),
            spreadRadius: 0.0,
          ),
        ],
        borderRadius: isMe
            ? BorderRadius.only(
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              )
            : BorderRadius.only(
                topRight: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0),
                topLeft: Radius.circular(15.0),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SelectableLinkify(
            onOpen: (link) async {
              if (await canLaunch(link.url)) {
                await launch(link.url);
              } else {
                throw 'Could not launch $link';
              }
            },
            text: message["message"].trim(),
            style: TextStyle(
              color: (isMe) ? kWhite : kTextColor,
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
            ),
            linkStyle: TextStyle(color: kAccentColor),
            options: LinkifyOptions(humanize: false),
          ),
          // Text(
          //   message["message"].trim(),
          //   style: TextStyle(
          //     color: (isMe) ? kWhite : kTextColor,
          //     fontSize: 15.0,
          //     fontWeight: FontWeight.w500,
          //   ),
          //   textAlign: TextAlign.start,
          // ),
          SizedBox(height: 4.0),
          Text(
            postedOnString,
            style: TextStyle(
              color: (!isMe) ? kGrey : kTextColor,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );

    return msg;
  }

  @override
  void initState() {
    super.initState();
    _chatRoomId = widget.friend["chats"][currentId];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SingleUserScreen(widget.frienId)));
          },
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                height: AppBar().preferredSize.height,
                width: AppBar().preferredSize.height,
                child: FancyShimmerImage(
                  imageUrl: widget.friend["photoUrl"],
                  boxFit: BoxFit.cover,
                ),
              ),
              Text(
                widget.friend["name"],
                style: TextStyle(
                  color: kTextColor,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kBGColor,
              ),
              child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection("chatRooms")
                      .doc(_chatRoomId)
                      .collection("chats")
                      .orderBy("postedOn", descending: true)
                      .snapshots(),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    if (snapshot.data == null)
                      return Center(
                        child: Text("Start Messaging..."),
                      );

                    var chats = snapshot.data.docs;
                    return ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.only(
                        top: 15.0,
                        left: kDefaultPadding,
                        right: kDefaultPadding,
                      ),
                      itemBuilder: (ctx, i) {
                        var message = chats[i];
                        bool isMe = currentId == message["postedBy"];
                        return _buildMessage(message.data(), isMe);
                      },
                      itemCount: chats.length,
                    );
                  }),
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.photo),
          //   iconSize: 25.0,
          //   color: Theme.of(context).primaryColor,
          //   onPressed: () {},
          // ),
          Expanded(
            child: TextField(
              onSubmitted: (val) {
                _sendMessage();
              },
              controller: messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String _message = messageController.value.text.trim();
    if (_message.length < 1 || _message == null) return;
    await _firestore
        .collection("chatRooms")
        .doc(_chatRoomId)
        .collection("chats")
        .add({
      "message": _message,
      "postedOn": Timestamp.now(),
      "postedBy": currentId,
    });

    messageController.clear();
  }
}
