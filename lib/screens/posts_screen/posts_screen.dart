import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../components/ads_component.dart';
import '../../components/create_post_component.dart';
import '../../components/empty_state_component.dart';
import '../../components/post_widget.dart';


class PostsScreen extends StatefulWidget {
  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  ScrollController _scrollController = ScrollController();
  final int perPage = 20;
  final String uid = FirebaseAuth.instance.currentUser.uid;
  bool _hasMorePosts = true;
  DocumentSnapshot _lastDocument;
  List<List<QueryDocumentSnapshot>> _allPagedResults =
      List<List<QueryDocumentSnapshot>>();
  List<String> _frnds = [];

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

  var _postsCollectionReference = FirebaseFirestore.instance
      .collection("posts")
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

        _postsController.add(allPosts.where((element) {
          final _data = element.data();
          return _frnds.contains(_data["postedBy"]);
        }).toList());

        // Save the last document from the results only if it's the current last page
        if (currentRequestIndex == _allPagedResults.length - 1) {
          _lastDocument = postsSnapshot.docs.last;
        }
        // Determine if there's more posts to request
        _hasMorePosts = (posts.length == perPage);
      }
    });
  }

  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection("users").doc(uid).get(),
      builder: (_, info) {
        if (info.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(),
          );
        final data = info.data.data();

        if (data["friends"] != null) {
          Map<String, dynamic> _all = data["friends"];
          _all.removeWhere((key, value) => value != 3);
          _frnds = _all.keys.toList();
          _frnds.add(uid);
        }

        if (_frnds.length == 0)
          return Column(
            children: [
              CreatePostComponent(),
              AdsComponent(),
              Expanded(
                child: SingleChildScrollView(
                  child: EmptyStateComponent(
                    "Make some friends to see their Posts.",
                  ),
                ),
              ),
            ],
          );
        return StreamBuilder<List<QueryDocumentSnapshot>>(
          stream: listenToPostsRealTime(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(
                child: CircularProgressIndicator(),
              );

            if (snapshot.hasData) {
              var data = snapshot.data;
              if (data.length > 0)
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: data.length + 2,
                  itemBuilder: (ctx, i) {
                    if(i==0)
                      return CreatePostComponent();
                    if(i==1)
                      return AdsComponent();
                    return PostWidget(
                      key: Key(data[i-2].id),
                      post: data[i-2],
                    );
                  },
                );
            }

            return Column(
              children: [
                CreatePostComponent(),
                AdsComponent(),
                Expanded(
                  child: SingleChildScrollView(
                    child: EmptyStateComponent("No Posts Found."),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}


