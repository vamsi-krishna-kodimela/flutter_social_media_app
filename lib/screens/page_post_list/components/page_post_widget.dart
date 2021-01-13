import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media/screens/comments_screen/comments_screen.dart';
import 'package:social_media/screens/likes_screen/likes_screen.dart';
import 'package:social_media/screens/single_page_screen/single_page_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../constants.dart';

class PagePostWidget extends StatefulWidget {
  final post;

  PagePostWidget({Key key, this.post}) : super(key: key);

  @override
  _PagePostWidgetState createState() => _PagePostWidgetState();
}

class _PagePostWidgetState extends State<PagePostWidget> {
  final String _authId = FirebaseAuth.instance.currentUser.uid;
  Map<String, dynamic> _postData = {};
  Map<String, dynamic> likes = {};
  bool isLiked = false;
  int likesCount = 0;
  bool isExpanded = false;
  GestureRecognizer _gestureRecognizer;

  VideoPlayerController _videoPlayerController;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    _postData = widget.post.data();
    likes = _postData["likes"];
    if (likes != null) {
      likesCount =
          likes.values.where((element) => element == true).toList().length;

      isLiked = likes[_authId];
    }
    if (isLiked == null) isLiked = false;
    if (_postData != null) {
      if (_postData["type"] != 0 &&
          _postData["resources"] != null &&
          _postData["resources"] != "") {
        _videoPlayerController =
        VideoPlayerController.network(_postData["resources"])
          ..initialize().then((_) {
            setState(() {
              _videoPlayerController.setLooping(true);
              _videoPlayerController.setVolume(0);
            });
          });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _gestureRecognizer.dispose();
    if (_postData["type"] == 1) {
      _videoPlayerController.dispose();
    }
  }

  bool audioState = false;

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final DateTime postedOn = _postData["postedOn"].toDate();
    final Duration _dur = DateTime.now().difference(postedOn);
    _gestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          isExpanded = !isExpanded;
        });
      };

    void _toggleMute(isMuted) {
      audioState = !isMuted;

      setState(() {
        if (isMuted)
          _videoPlayerController.setVolume(0);
        else
          _videoPlayerController.setVolume(100);
      });
    }

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

    toogleLikes() async {
      bool _isLiked = isLiked;
      if (_isLiked) {
        widget.post.reference.update({'likes.$_authId': false});
        setState(() {
          isLiked = false;
          likesCount -= 1;
          if (likes == null) {
            likes = {_authId: false};
          } else {
            likes[_authId] = false;
          }
        });
      } else if (!_isLiked) {
        widget.post.reference.update({'likes.$_authId': true});
        setState(() {
          isLiked = true;
          likesCount += 1;
          if (likes == null) {
            likes = {_authId: true};
          } else {
            likes[_authId] = true;
          }
        });
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: kDefaultPadding ,
        vertical: kDefaultPadding,
      ),
      decoration: BoxDecoration(
        color: kWhite,
        boxShadow: [
          BoxShadow(
            color: kGrey.withAlpha(50),
            spreadRadius: 0,
            offset: Offset(0, 0),
            blurRadius: 4,
          ),
        ],
      ),
      child: VisibilityDetector(
        key: Key(widget.post.id),
        onVisibilityChanged: (info) {
          if (_postData["type"] == 1) {
            if (info.visibleFraction > 0.8)
              _videoPlayerController.play();
            else {
              if (mounted) _videoPlayerController.pause();
            }
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: kDefaultPadding,
            vertical: kDefaultPadding,
          ),
          child: Column(
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection("pages").doc(_postData["page"]).get(),
                builder: (ctx, snapshot) {
                  if (snapshot.data == null) {
                    return ListTile(
                      leading: Container(
                        width: _size.width * 0.1,
                        height: _size.width * 0.1,
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
                  );
                },
              ),
              if (_postData["resources"] != null &&
                  _postData["resources"] != "")
                (_postData["type"] == 0)
                    ? FancyShimmerImage(
                  width: _size.width - (kDefaultPadding * 4),
                  height:
                  (_size.width - (kDefaultPadding * 4)) * (3 / 4),
                  imageUrl: _postData["resources"],
                  boxFit: BoxFit.cover,
                )
                    : Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 4/3,
                      child: SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoPlayerController.value.size?.width ?? 0,
                            height: _videoPlayerController.value.size?.height ?? 0,
                            child: VideoPlayer(_videoPlayerController),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        child: IconButton(
                          color: (audioState)
                              ? kPrimaryColor
                              : kAccentColor,
                          icon: Icon(
                            !audioState
                                ? Icons.volume_off
                                : Icons.volume_up,
                          ),
                          onPressed: () {
                            _toggleMute(audioState);
                          },
                        ),
                      ),
                      bottom: 10.0,
                      right: 10.0,
                    ),
                  ],
                ),
              Container(
                padding: EdgeInsets.symmetric(vertical: kDefaultPadding),
                width: double.infinity,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: (_postData["description"] == null)
                            ? ""
                            : (isExpanded ||
                            _postData["description"].length <= 20)
                            ? _postData["description"]
                            : "${_postData["description"].substring(0, 20)} .....          ",
                        style: TextStyle(color: kTextColor),
                      ),
                      TextSpan(
                        text: (_postData["description"] == null)
                            ? ""
                            : (_postData["description"].length <= 20)
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
              _PostFooter(
                isLiked: isLiked,
                likesCount: likesCount,
                widget: widget,
                toogleLikes: toogleLikes,
                likedList: likes,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostFooter extends StatelessWidget {
  const _PostFooter({
    Key key,
    @required this.isLiked,
    @required this.likesCount,
    @required this.widget,
    @required this.toogleLikes,
    this.likedList,
  }) : super(key: key);

  final bool isLiked;
  final int likesCount;
  final PagePostWidget widget;
  final Function toogleLikes;
  final Map<String, dynamic> likedList;

  @override
  Widget build(BuildContext context) {
    List<String> likesList = [];
    if (likedList != null) {
      for (String key in likedList.keys) {
        if (likedList[key] == true) likesList.add(key);
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FlatButton.icon(
              onPressed: toogleLikes,
              icon: Icon(
                (isLiked) ? Icons.favorite : Icons.favorite_border,
                color: kAccentColor,
              ),
              label: GestureDetector(
                  onTap: () {
                    if (likesCount > 0)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LikesScreen(
                            likedBy: likesList,
                          ),
                        ),
                      );
                  },
                  child: Text("$likesCount likes")),
            ),
            IconButton(
              icon: Icon(
                Icons.comment_outlined,
                color: kPrimaryColor,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CommentsScreen(
                      postId: widget.post.id,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.share,
            color: kTextColor,
          ),
          onPressed: () {
            Share.share(
                "https://friendzit.in/pg/${widget.post.id}"
            );
          },
        ),
      ],
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
  })  : _size = size,
        _userInfo = userInfo,
        super(key: key);

  final Size _size;
  final Map<String, dynamic> _userInfo;
  final String postedOnString;
  final String uid;
  final String postId;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (uid != FirebaseAuth.instance.currentUser.uid) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SinglePageScreen(pageId: uid),
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
            imageUrl: _userInfo["pic"],
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
      trailing: (_userInfo["createdBy"] == FirebaseAuth.instance.currentUser.uid)
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
                          .collection("page_posts")
                          .doc(postId)
                          .delete();
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
