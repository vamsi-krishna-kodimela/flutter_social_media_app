import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/likes_screen/likes_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../constants.dart';

class VideoPlayerComponent extends StatefulWidget {
  final Map<String, dynamic> data;
  final DocumentReference reference;

  const VideoPlayerComponent({Key key, this.data, this.reference})
      : super(key: key);

  @override
  _VideoPlayerComponentState createState() => _VideoPlayerComponentState();
}

class _VideoPlayerComponentState extends State<VideoPlayerComponent> {
  Map<String, dynamic> data;
  VideoPlayerController _videoPlayerController;

  final uid = FirebaseAuth.instance.currentUser.uid;

  bool isLiked;
  int likesCount;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    isLiked = !(data["likes"] == null || data["likes"][uid] != true);
    likesCount = likesCounter(data["likes"]);
    _videoPlayerController = VideoPlayerController.network(data["resource"])
      ..initialize().then((_) {
        if (mounted)
          setState(() {
            _videoPlayerController.setLooping(true);
          });
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(DateTime.now().toString()),
      onVisibilityChanged: (info) {
        if (mounted) if (info.visibleFraction > 0.95) {
          _videoPlayerController.play();
        } else {
          _videoPlayerController.pause();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: GestureDetector(
                onTap: () {
                  if (_videoPlayerController.value.isPlaying) {
                    _videoPlayerController.pause();
                  } else {
                    _videoPlayerController.play();
                  }
                },
                child: AspectRatio(
                  aspectRatio: 5 / 4,
                  child: (_videoPlayerController.value.initialized)
                      ? SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width:
                                  _videoPlayerController.value.size?.width ?? 0,
                              height:
                                  _videoPlayerController.value.size?.height ??
                                      0,
                              child: VideoPlayer(_videoPlayerController),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: kGrey,
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              child: Row(
                children: [
                  GestureDetector(
                    child: Text("$likesCount Likes"),
                    onTap: () {
                      if (likesCount > 0) {
                        final _likes = data["likes"].keys.toList();
                        final lk = _likes
                            .where((e) => data["likes"][e.toString()] == true)
                            .toList();
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => LikesScreen(
                            likedBy: lk,
                          ),
                        ));
                      }
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      toogleLikes();
                    },
                    icon: Icon(
                      (!isLiked)
                          ? Icons.favorite_border_rounded
                          : Icons.favorite_rounded,
                      color: kAccentColor,
                    ),
                  ),
                ],
              ),
              right: 10.0,
              bottom: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  int likesCounter(Map<String, dynamic> likes) {
    if (likes == null) return 0;
    var _likes = likes.values.toList();
    _likes.removeWhere((element) => element == false);
    return _likes.length;
  }

  void toogleLikes() async {
    isLiked = !isLiked;
    if (isLiked)
      likesCount++;
    else
      likesCount--;
    await widget.reference.update({"likes.$uid": isLiked});
    setState(() {});
  }
}
