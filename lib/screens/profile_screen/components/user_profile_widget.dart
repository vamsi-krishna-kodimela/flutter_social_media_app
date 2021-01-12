import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/friends_screen/friends_screen.dart';

import '../../../constants.dart';
import 'user_profile_actions.dart';

class UserProfileWidget extends StatelessWidget {
  UserProfileWidget(this.uid);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid;
  final User _current = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection("users").doc(uid).snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data.data();
          final Map<String, dynamic> _friends = data["friends"];
          List<dynamic> friends;
          if (_friends == null)
            friends = [];
          else
            friends = _friends.values.toList();
          friends..removeWhere((element) => element != 3);
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(kDefaultPadding * 2),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(kDefaultPadding * 2 + 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: kGrey,
                  offset: Offset(0.0, 0.0),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _UserProfilePic(size: _size, photoUrl: data["photoUrl"]),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: kDefaultPadding*2,bottom: kDefaultPadding),
                            child: _UserNameWidget(name: data["name"]),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    (data["postCount"] == null)
                                        ? "0"
                                        : data["postCount"].toString(),
                                    style: TextStyle(
                                      color: kTextColor,
                                      fontSize: 16.0,
                                      fontStyle: FontStyle.italic
                                    ),
                                  ),
                                  Text(
                                    "Posts",
                                    style: TextStyle(
                                      color: kTextColor,
                                    ),
                                  )
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  List<String> friendsList = [];
                                  for (String key in _friends.keys) {
                                    if (_friends[key] == 3) {
                                      friendsList.add(key);
                                    }
                                  }

                                  if (friends.length > 0)
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => FriendsScreen(
                                          likedBy: friendsList,
                                        ),
                                      ),
                                    );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      friends.length.toString(),
                                      style: TextStyle(
                                          color: kTextColor,
                                          fontSize: 16.0,
                                          fontStyle: FontStyle.italic
                                      ),
                                    ),
                                    Text(
                                      "Friends",
                                      style: TextStyle(
                                        color: kTextColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (data["description"] != null &&
                              data["description"].length > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding*2,vertical: kDefaultPadding),
                              child: UserDescriptionWidget(description: data["description"]),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                UserProfileActions(
                  data: data,
                  current: _current,
                  id: snapshot.data.id,
                ),
              ],
            ),
          );
        }
        return Text("Loading...");
      },
    );
  }
}

class UserDescriptionWidget extends StatelessWidget {
  const UserDescriptionWidget({
    Key key,
    @required this.description,
  }) : super(key: key);

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Text(
        "$description",
        style: TextStyle(
          color: kTextColor,
          fontSize: 14.0,
        ),
      ),
    );
  }
}

class _UserNameWidget extends StatelessWidget {
  const _UserNameWidget({
    Key key,
    @required this.name,
  }) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        name,
        style: TextStyle(
          color: kTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 18.0,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _UserProfilePic extends StatelessWidget {
  const _UserProfilePic({
    Key key,
    @required Size size,
    @required this.photoUrl,
  })  : _size = size,
        super(key: key);

  final Size _size;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size.width * 0.2,
      height: _size.width * 0.2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kDefaultPadding * 2),
        child: FancyShimmerImage(
          imageUrl: photoUrl,
          boxFit: BoxFit.cover,
        ),
      ),
    );
  }
}
