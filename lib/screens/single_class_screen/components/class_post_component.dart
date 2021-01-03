import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media/screens/comments_screen/comments_screen.dart';
import 'package:social_media/screens/likes_screen/likes_screen.dart';
import 'package:social_media/screens/single_user_screen/single_user_screen.dart';
import 'package:string_validator/string_validator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants.dart';

class ClassPostComponent extends StatefulWidget {
  final post;
  final Function emptyStream;

  const ClassPostComponent({Key key, this.post,this.emptyStream}) : super(key: key);

  @override
  _ClassPostComponentState createState() => _ClassPostComponentState();
}

class _ClassPostComponentState extends State<ClassPostComponent> {
  final _uid = FirebaseAuth.instance.currentUser.uid;
  final _firestore = FirebaseFirestore.instance;
  bool isExpanded = false;
  GestureRecognizer _gestureRecognizer;
  bool isLiked = false;

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> _postData = widget.post.data();
    final _size = MediaQuery.of(context).size;
    _gestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          isExpanded = !isExpanded;
        });
      };
    List<dynamic> _likes = [];
    if (_postData["likes"] != null)_likes = _postData["likes"];

    isLiked = _likes.contains(_uid);
    final DateTime postedOn = _postData["postedOn"].toDate();
    final Duration _dur = DateTime.now().difference(postedOn);

    String postedOnString;
    if (_dur.inSeconds < 2) {
      postedOnString = "Posted Just Now";
    } else if (_dur.inSeconds < 60) {
      postedOnString = "Posted ${_dur.inSeconds} seconds ago";
    } else if (_dur.inMinutes < 60) {
      postedOnString = "Posted ${_dur.inMinutes} minutes ago";
    } else if (_dur.inHours < 24) {
      postedOnString = "Posted ${_dur.inHours} hours ago";
    } else if (_dur.inDays < 20) {
      postedOnString = "Posted ${_dur.inDays} days ago";
    } else {
      postedOnString =
      "Posted on ${DateFormat("dd MMM, yyyy").format(postedOn)}";
    }


    return ClipRRect(
      borderRadius: BorderRadius.circular(kDefaultPadding),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kDefaultPadding),
          color: kWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 0.0,
              offset: Offset(0, 0),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
        margin: EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: _postData["userData"].get(),
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
                  postId: widget.post.id,
                  emptyStream: widget.emptyStream,
                );
              },
            ),
            if (_postData["resources"] != null && isURL(_postData["resources"]))
              AspectRatio(
                aspectRatio: 3 / 2,
                child: FancyShimmerImage(
                  imageUrl: _postData["resources"],
                ),
              ),
            if (_postData["link"] != null && isURL(_postData["link"]))
              GestureDetector(
                onTap: () {
                  _launchURL(_postData["link"]);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: kBGColor,
                    borderRadius: BorderRadius.circular(kDefaultPadding),
                  ),
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: FlutterLinkPreview(
                    url: _postData["link"],
                    titleStyle: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                    ),
                    bodyStyle: TextStyle(color: kTextColor),
                  ),
                ),
              ),
            if (_postData["description"] != null)
              Container(
                padding: EdgeInsets.all(kDefaultPadding),
                width: double.infinity,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: (_postData["description"] == null)
                            ? ""
                            : (isExpanded ||
                                    _postData["description"].length <= 50)
                                ? _postData["description"]
                                : "${_postData["description"].substring(0, 50)} .....          ",
                        style: TextStyle(color: kTextColor),
                      ),
                      TextSpan(
                        text: (_postData["description"] == null)
                            ? ""
                            : (_postData["description"].length <= 50)
                                ? ""
                                : (isExpanded)
                                    ? "        see less "
                                    : "       see more ",
                        style: TextStyle(
                          color: kAccentColor,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: _gestureRecognizer,
                      ),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: kAccentColor,
                      ),
                      onPressed: () async {
                        if (!isLiked)
                          await widget.post.reference.update({
                            "likes": FieldValue.arrayUnion([_uid]),
                          });
                        else
                          await widget.post.reference.update({
                            "likes": FieldValue.arrayRemove([_uid]),
                          });
                      },
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (_)=>LikesScreen(likedBy: _likes,)));
                      },
                      child: Text(
                        "${_likes.length} likes",
                        style: TextStyle(
                          color: kTextColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: kDefaultPadding,
                ),
                IconButton(
                  icon: Icon(
                    Icons.comment_outlined,
                    color: kPrimaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_)=>CommentsScreen(postId: widget.post.id,)));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
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
    @required this.postId,
    @required this.emptyStream,
  })  : _size = size,
        _userInfo = userInfo,
        super(key: key);

  final Size _size;
  final Map<String, dynamic> _userInfo;
  final String postedOnString;
  final String uid;
  final String postId;
  final Function emptyStream;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (uid != FirebaseAuth.instance.currentUser.uid) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SingleUserScreen(uid, _userInfo["name"]),
            ),
          );
        }
      },
      contentPadding: EdgeInsets.all(0.0),
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
      trailing: (uid == FirebaseAuth.instance.currentUser.uid)
          ? IconButton(
        icon: Icon(
          Icons.delete_outline_outlined,
          color: kAccentColor,
        ),
        onPressed: () async {
          await showDialog(
            builder: (ctx) {
              return AlertDialog(
                title: Text(
                  "Are you Sure to delete?",
                  style: TextStyle(
                    color: kTextColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  FlatButton(
                    color: kPrimaryColor.withAlpha(20),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("class_posts")
                          .doc(postId)
                          .delete();
                      emptyStream();
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      "Yes",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FlatButton(
                    color: kAccentColor,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      "No",
                      style: TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
            context: context,
          );
        },
      )
          : Text(""),
    );
  }
}