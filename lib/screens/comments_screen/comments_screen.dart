import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants.dart';
import '../single_user_screen/single_user_screen.dart';

class CommentsScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController commentController = TextEditingController();
  final String postId;
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  final String uid = FirebaseAuth.instance.currentUser.uid;

  CommentsScreen({Key key, this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text(
          "Comments",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("comments")
                  .where("postId", isEqualTo: postId)
                  .orderBy("postedOn", descending: true)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                if (snapshot.data == null)
                  return Center(
                    child: Text("No Comments yet..."),
                  );
                var comments = snapshot.data.docs;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (_, i) {
                    var data = comments[i].data();
                    return FutureBuilder<DocumentSnapshot>(
                      future: data["postedBy"].get(),
                        builder: (_, res) {
                        var _userInfo;
                        if(res.data != null)
                          _userInfo = res.data.data();

                        final DateTime postedOn = data["postedOn"].toDate();
                        final Duration _dur = DateTime.now().difference(postedOn);
                        String postedOnString;
                        if (_dur.inSeconds < 2) {
                          postedOnString = "Commented Just Now";
                        } else if (_dur.inSeconds < 60) {
                          postedOnString = "Commented ${_dur.inSeconds} seconds ago";
                        } else if (_dur.inMinutes < 60) {
                          postedOnString = "Commented ${_dur.inMinutes} minutes ago";
                        } else if (_dur.inHours < 24) {
                          postedOnString = "Commented ${_dur.inHours} hours ago";
                        } else if (_dur.inDays < 20) {
                          postedOnString = "Commented ${_dur.inDays} days ago";
                        } else {
                          postedOnString =
                          "Commented on ${DateFormat("dd MMM, yyyy").format(postedOn)}";
                        }


                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 1.0,),
                            child: ListTile(
                              leading: GestureDetector(
                                onTap: (){
                                  if(_userInfo != null)Navigator.of(context).push(MaterialPageRoute(builder: (_)=>SingleUserScreen(res.data.id)));
                                },
                                child: Container(
                                  width: _size.width * 0.1,
                                  height: _size.width * 0.1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(kDefaultPadding),
                                    child: (_userInfo == null)?Text(""):FancyShimmerImage(
                                      imageUrl: _userInfo["photoUrl"],
                                      boxFit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              title: Linkify(
                                onOpen: (link) async {
                                  if (await canLaunch(link.url)) {
                                    await launch(link.url);
                                  } else {
                                    throw 'Could not launch $link';
                                  }
                                },
                                text: data["comment"],
                                style: TextStyle(color: kTextColor),
                                linkStyle: TextStyle(color: Colors.red),
                              ),
                              subtitle: Text(postedOnString),
                            ),
                          );
                        }
                    );
                  },
                );
              },
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
            icon: Icon(Icons.comment_outlined),
            iconSize: 25.0,
            color: kPrimaryColor,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              onSubmitted: (val) async {},
              controller: commentController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration.collapsed(
                hintText: 'Add Comment...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: kPrimaryColor,
            onPressed: () async {
              await _addComment();
            },
          ),
        ],
      ),
    );
  }


  _addComment()async{
    var _com = commentController.value.text.trim();
    if(_com.length<1)
      return;
    await _firestore.collection("comments").add({
      "comment":_com,
      "postId":postId,
      "postedOn" : Timestamp.now(),
      "postedBy" : _firestore.collection("users").doc(uid),
    });
    commentController.clear();
  }
}
