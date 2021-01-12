import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../constants.dart';
import 'components/author_details.dart';
import 'components/post_footer.dart';


class GroupPostWidgetComponent extends StatefulWidget {
  final post;
  final Function function;

  GroupPostWidgetComponent({Key key, this.post,this.function}) : super(key: key);

  @override
  _GroupPostWidgetComponent createState() => _GroupPostWidgetComponent();
}

class _GroupPostWidgetComponent extends State<GroupPostWidgetComponent> {
  final String _authId = FirebaseAuth.instance.currentUser.uid;
  Map<String, dynamic> _postData = {};
  Map<String, dynamic> likes = {};
  bool isLiked = false;
  int likesCount = 0;
  bool isExpanded = false;
  GestureRecognizer _gestureRecognizer;

  VideoPlayerController _videoPlayerController;

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
        horizontal: kDefaultPadding * 1.5,
        vertical: kDefaultPadding,
      ),
      decoration: BoxDecoration(
        color: kWhite,
        // borderRadius: BorderRadius.circular(kDefaultPadding),
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
            horizontal: kDefaultPadding * 2,
            vertical: kDefaultPadding,
          ),

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
                  return AuthorDetails(
                    size: _size,
                    userInfo: _userInfo,
                    postedOnString: postedOnString,
                    uid: snapshot.data.id,
                    postId: widget.post.id,
                    gid: _postData["gid"],
                    function:widget.function,
                  );
                },
              ),
              if (_postData["resources"] != null &&
                  _postData["resources"] != "")
                ClipRRect(
                  borderRadius: BorderRadius.circular(kDefaultPadding),
                  child: (_postData["type"] == 0)
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
                        aspectRatio: 4 / 3,
                        child: VideoPlayer(_videoPlayerController),
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
              PostFooter(
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



