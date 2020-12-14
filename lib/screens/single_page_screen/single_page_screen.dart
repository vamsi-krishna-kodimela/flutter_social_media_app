import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/create_page_post_screen/create_page_post_screen.dart';
import 'package:social_media/screens/create_page_screen/edit_page_screen.dart';
import 'package:social_media/screens/page_post_list/page_post_list.dart';
import '../../constants.dart';

class SinglePageScreen extends StatefulWidget {
  final String pageId;
  final String pageName;

  const SinglePageScreen({@required this.pageId, @required this.pageName});

  @override
  _SinglePageScreenState createState() => _SinglePageScreenState();
}

class _SinglePageScreenState extends State<SinglePageScreen> {
  final _firestore = FirebaseFirestore.instance;

  final _scaffold = GlobalKey<ScaffoldState>();
  final _uid = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffold,
      appBar: AppBar(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("pages").doc(widget.pageId).snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData)
            return Center(
              child: Text("Page Not Found in Our Records."),
            );
          DocumentSnapshot _doc = snapshot.data;
          Map<String, dynamic> _data = _doc.data();
          List<dynamic> _followers = [];
          if (_data["followers"] == null) _followers = _data["followers"];

          return Column(
            children: [
              Container(
                width: _size.width,
                padding: EdgeInsets.symmetric(horizontal: kDefaultPadding * 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(kDefaultPadding),
                      child: FancyShimmerImage(
                        imageUrl: _data["pic"],
                        width: _size.width * 0.2,
                        height: _size.width * 0.2,
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(kDefaultPadding)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                (_data["name"] == null) ? "" : _data["name"],
                                style: TextStyle(
                                  color: kTextColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.info_outline_rounded,
                                    size: 20.0,
                                  ),
                                  color: kPrimaryColor,
                                  onPressed: () {
                                    _scaffold.currentState
                                        .showBottomSheet((context) {
                                      return Container(
                                        height: _size.height * 0.5,
                                        padding:
                                            EdgeInsets.all(kDefaultPadding * 2),
                                        decoration: BoxDecoration(
                                          color: kWhite,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(
                                                kDefaultPadding * 2),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0, 0),
                                              color: Colors.black12,
                                              blurRadius: 8.0,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  width: _size.width,
                                                  padding: EdgeInsets.only(
                                                      top: kDefaultPadding),
                                                  child: Text(
                                                    _data["description"],
                                                    style: TextStyle(
                                                      color: kTextColor,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                                  }),
                            ],
                          ),
                          SizedBox(height: kDefaultPadding),
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      (_data["posts"] == null)
                                          ? 0
                                          : _data["posts"].toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    Text("Posts"),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      _followers.length.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    Text("Followers"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: kDefaultPadding),
                          (_data["createdBy"] == _uid)
                              ? Container(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: FlatButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    CreatePagePostScreen(
                                                        widget.pageId),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.add,
                                            color: kWhite,
                                          ),
                                          label: Text(
                                            "Create Post",
                                            style: TextStyle(color: kWhite),
                                          ),
                                          color: kPrimaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                kDefaultPadding),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: kDefaultPadding,
                                      ),
                                      OutlineButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(MaterialPageRoute(builder: (_)=>EditPageScreen(snapshot.data)));
                                        },
                                        icon: Icon(Icons.edit),
                                        label: Text("Edit Info"),
                                        textColor: kAccentColor,
                                        borderSide:
                                            BorderSide(color: kAccentColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              kDefaultPadding),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: FlatButton(
                                          onPressed: () {
                                            if (_followers.contains(_uid)) {
                                              _firestore.collection("pages").doc(widget.pageId).update(
                                                {
                                                  "followers":FieldValue.arrayRemove([_uid]),
                                                }
                                              );
                                            } else {
                                              _firestore.collection("pages").doc(widget.pageId).update(
                                                  {
                                                    "followers":FieldValue.arrayUnion([_uid]),
                                                  }
                                              );
                                            }
                                          },
                                          child: Text(
                                            (_followers.contains(_uid))
                                                ? "Unfollow"
                                                : "Follow",
                                            style: TextStyle(color: kWhite),
                                          ),
                                          color: (_followers.contains(_uid))
                                              ? kAccentColor
                                              : kPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PagePostListScreen(widget.pageId),
              ),
            ],
          );
        },
      ),
    );
  }
}
