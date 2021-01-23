import 'dart:io';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/create_post_screen/create_post_screen.dart';
import '../screens/profile_screen/profile_screen.dart';

import '../constants.dart';
import './image_source_selector.dart';


class CreatePostComponent extends StatelessWidget {
  User _user = FirebaseAuth.instance.currentUser;
  File _file;
  int _type;

  void setImage(File img, int type) {
    _type = type;
    _file = img;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 0.5,
              color: kGrey,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding,
              vertical: kDefaultPadding * 1.5,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    minRadius: kDefaultPadding,
                    maxRadius: kDefaultPadding * 2.5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: FancyShimmerImage(
                        imageUrl: _user.photoURL,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: kDefaultPadding,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CreatePostScreen(),
                      ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(kDefaultPadding * 4),
                        border: Border.all(
                          color: kGrey,
                          width: 0.75,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: kDefaultPadding * 2,
                        horizontal: kDefaultPadding * 2,
                      ),
                      child: Text("What's on Your Mind..."),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: FlatButton.icon(
                onPressed: () async {
                  await DialogCameraPicker.buildShowDialog(
                      type: 0,
                      setImage: setImage,
                      context: context,
                      isPost: true);
                  if (_file != null)
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreatePostScreen(
                          type: _type,
                          file: _file,
                        ),
                      ),
                    );
                },
                icon: Icon(
                  Icons.image,
                  color: kPrimaryColor,
                ),
                label: Text(
                  "Add Photo",
                  style: TextStyle(
                    color: kTextColor,
                  ),
                ),
              ),
            ),
            Container(
              width: 0.5,
              height: 30,
              color: Colors.grey,
            ),
            Expanded(
              child: FlatButton.icon(
                onPressed: () async {
                  await DialogCameraPicker.buildShowDialog(
                      type: 1,
                      setImage: setImage,
                      context: context,
                      isPost: true);
                  if (_file != null)
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreatePostScreen(
                          type: _type,
                          file: _file,
                        ),
                      ),
                    );
                },
                icon: Icon(
                  Icons.video_call,
                  color: kAccentColor,
                ),
                label: Text(
                  "Add Video",
                  style: TextStyle(
                    color: kTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}