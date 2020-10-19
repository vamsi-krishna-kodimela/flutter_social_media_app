import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/entertainment_upload_screen/entertainment_upload_screen.dart';

class EntertainmentScreen extends StatefulWidget {
  @override
  _EntertainmentScreenState createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  var currentOption = 0;

  void changeOption(val) {
    setState(() {
      currentOption = val;
    });
  }




  ScrollController _scrollController = ScrollController();
  final int perPage = 10;
  String uid;
  bool _hasMorePosts = true;
  DocumentSnapshot _lastDocument;
  List<List<QueryDocumentSnapshot>> _allPagedResults =
  List<List<QueryDocumentSnapshot>>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxScroll - currentScroll <= delta) _requestPosts();
    });

  }

  final StreamController<List<QueryDocumentSnapshot>> _postsController =
  StreamController<List<QueryDocumentSnapshot>>.broadcast();

  final _postsCollectionReference = FirebaseFirestore.instance
      .collection("entertainment")
      .orderBy("postedOn", descending: true);


  Stream listenToPostsRealTime() {
    _requestPosts();

    return _postsController.stream;
  }

  void _requestPosts() {
    var pagePostsQuery = _postsCollectionReference.limit(perPage);
    if (_lastDocument != null)
      pagePostsQuery = pagePostsQuery.startAfterDocument(_lastDocument);

    var currentRequestIndex = _allPagedResults.length;

    pagePostsQuery.snapshots().listen((postsSnapshot) {
      if (postsSnapshot.docs.isNotEmpty) {
        var posts = postsSnapshot.docs;
        var pageExists = currentRequestIndex < _allPagedResults.length;

        if (pageExists) {
          _allPagedResults[currentRequestIndex] = posts;
        } else {
          _allPagedResults.add(posts);
        }

        var allPosts = _allPagedResults.fold<List<QueryDocumentSnapshot>>(
            List<QueryDocumentSnapshot>(),
                (initialValue, pageItems) => initialValue..addAll(pageItems));

        _postsController.add(allPosts);

        // Save the last document from the results only if it's the current last page
        if (currentRequestIndex == _allPagedResults.length - 1) {
          _lastDocument = postsSnapshot.docs.last;
        }
        // Determine if there's more posts to request
        _hasMorePosts = (posts.length == perPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        title: Text("Entertainment"),
        elevation: 0.0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_)=>EntertainmentUploadScreen()));
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: kPrimaryColor,
            padding: EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TopBarOption(
                    isActive: currentOption == 0,
                    option: "All",
                    onPress: changeOption,
                    optionNum: 0,
                  ),
                  _TopBarOption(
                    isActive: currentOption == 1,
                    option: "Video",
                    onPress: changeOption,
                    optionNum: 1,
                  ),
                  _TopBarOption(
                    isActive: currentOption == 2,
                    option: "Audio",
                    onPress: changeOption,
                    optionNum: 2,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(

              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                color: kBGColor,
              ),
              child: Center(
                child: Text("Entertainment list"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBarOption extends StatelessWidget {
  final String option;
  final bool isActive;
  final Function onPress;
  final int optionNum;

  const _TopBarOption({
    this.option,
    this.isActive,
    this.onPress,
    this.optionNum,
  });




  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPress(optionNum);
      },
      child: Container(
        padding: EdgeInsets.only(left: kDefaultPadding, right: kDefaultPadding),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isActive ? kWhite : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
