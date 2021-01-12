import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/likes_screen/likes_screen.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../constants.dart';

class AudioPlayerComponent extends StatefulWidget {
  final Map<String, dynamic> data;
  final DocumentReference reference;

  const AudioPlayerComponent({Key key, this.data, this.reference})
      : super(key: key);

  @override
  _AudioPlayerComponentState createState() => _AudioPlayerComponentState();
}

class _AudioPlayerComponentState extends State<AudioPlayerComponent> {
  Map<String, dynamic> data;
  final uid = FirebaseAuth.instance.currentUser.uid;
  final AudioPlayer audioPlayer = AudioPlayer();

  bool isLiked;
  bool _isDisposed = false;
  int likesCount;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    isLiked = !(data["likes"] == null || data["likes"][uid] != true);
    likesCount = likesCounter(data["likes"]);

    audioPlayer.setUrl(data["resource"]);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(DateTime.now().toString()),
      onVisibilityChanged: (info) async {
        if (_isDisposed) return;
        if (info.visibleFraction > 0.95) {
          await audioPlayer.resume();
        } else {
          await audioPlayer.pause();
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
              child: AspectRatio(
                aspectRatio: 5 / 4,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: kGrey,
                      image: DecorationImage(
                        image: AssetImage("assets/audio_bg.jpg"),
                        fit: BoxFit.cover,
                      ),
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
                    onTap: (){
                      if (likesCount > 0) {
                        final _likes = data["likes"].keys.toList();
                        final lk = _likes.where((e)=>data["likes"][e.toString()]==true).toList();
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
                      if (mounted) toogleLikes();
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
