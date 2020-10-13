import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_media/constants.dart';

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
      postedOnString = "Commented ${_dur.inSeconds} secs ago";
    } else if (_dur.inMinutes < 60) {
      postedOnString = "Commented ${_dur.inMinutes} mins ago";
    } else if (_dur.inHours < 24) {
      postedOnString = "Commented ${_dur.inHours} hrs ago";
    } else {
      postedOnString =
      "Commented on ${DateFormat("dd MMM, yyyy").format(postedOn)}";
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
          Text(
            message["message"],
            style: TextStyle(
              color: (isMe) ? kWhite : kTextColor,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.start,
          ),
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
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.friend["name"],
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kBGColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(kDefaultPadding * 2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(kDefaultPadding * 2),
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
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              onSubmitted: (val) async {
                await _sendMessage();
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
            onPressed: () async {
              await _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    String _message = messageController.value.text;
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
