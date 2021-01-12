import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/single_class_screen/components/class_post_component.dart';

class ClassPostList extends StatefulWidget {
  final String cid;

  const ClassPostList(this.cid);

  @override
  _ClassPostListState createState() => _ClassPostListState();
}

class _ClassPostListState extends State<ClassPostList> {
  ScrollController _scrollController = ScrollController();
  final int perPage = 4;
  final String uid = FirebaseAuth.instance.currentUser.uid;
  bool _hasMorePosts = true;
  DocumentSnapshot _lastDocument;
  List<List<QueryDocumentSnapshot>> _allPagedResults =
      List<List<QueryDocumentSnapshot>>();

  emptyState() {
    if (_allPagedResults.length == 1)
      setState(() {
        _lastDocument = null;
        _allPagedResults = List<List<QueryDocumentSnapshot>>();
        _hasMorePosts = false;
      });
  }

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
      .collection("class_posts")
      .orderBy("postedOn", descending: true);

  Stream listenToPostsRealTime() {
    _requestPosts();
    return _postsController.stream;
  }

  void _requestPosts() {
    var pagePostsQuery = _postsCollectionReference
        .where("class", isEqualTo: widget.cid)
        .limit(perPage);
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
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: listenToPostsRealTime(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(),
          );

        if (snapshot.hasData) {
          var data = snapshot.data;
          if (data.length == 0)
            return Center(
              child: Text("No Posts Found"),
            );
          if (data.length > 0)
            return ListView.builder(
              controller: _scrollController,
              itemCount: data.length,
              itemBuilder: (ctx, i) {
                return ClassPostComponent(
                  key: Key(data[i].id),
                  post: data[i],
                  emptyStream: emptyState,
                );
              },
            );
        }

        return Center(
          child: Text("No Posts Found"),
        );
      },
    );
  }
}
