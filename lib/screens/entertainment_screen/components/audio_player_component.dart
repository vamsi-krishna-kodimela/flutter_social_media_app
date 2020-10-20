import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  int likesCount;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    isLiked = !(data["likes"] == null || data["likes"][uid] != true);
    likesCount = likesCounter(data["likes"]);
    audioPlayer.setUrl(data["resource"]).then((value) async {
      int result = await audioPlayer.resume();
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    audioPlayer.dispose();
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
              child: Container(
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
                  onPressed: () async {
                    await toogleLikes();
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

  play(String url) async {
    int result = await audioPlayer.play(url);
  }
}
