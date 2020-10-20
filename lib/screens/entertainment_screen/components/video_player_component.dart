import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../constants.dart';

class VideoPlayerComponent extends StatefulWidget {
  final Map<String, dynamic> data;
  final DocumentReference reference;

  const VideoPlayerComponent({Key key, this.data,this.reference}) : super(key: key);

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
    isLiked = !(data["likes"]==null||data["likes"][uid]!=true);
    likesCount = likesCounter(data["likes"]);
    _videoPlayerController = VideoPlayerController.network(data["resource"])
      ..initialize().then((_) {
        if (mounted)
          setState(() {
            _videoPlayerController.setLooping(true);
            _videoPlayerController.play();
          });
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: (_videoPlayerController.value.initialized)
                  ? VideoPlayer(_videoPlayerController)
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: kGrey,
                      ),
                    ),
            ),
          ),
          Positioned(
            child: Row(
              children: [
                Text("$likesCount Likes"),
                IconButton(
                  onPressed: () async{
                    await toogleLikes();
                  },
                  icon: Icon(
                    (!isLiked)?Icons.favorite_border_rounded:Icons.favorite_rounded,
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
    );
  }

  int likesCounter(Map<String, dynamic> likes){
    if(likes == null)
      return 0;
    var _likes = likes.values.toList();
    _likes.removeWhere((element) => element==false);
    return _likes.length;
  }

  void toogleLikes()async{
    isLiked = !isLiked;
    if(isLiked)likesCount++;else likesCount--;
    await widget.reference.update({"likes.$uid":isLiked});
    setState(() {

    });
  }
}
