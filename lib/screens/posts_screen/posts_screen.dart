
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/post_widget.dart';

class PostsScreen extends StatefulWidget {

  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  ScrollController _scrollController = ScrollController();
  final int perPage = 4;
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
        if(snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator(),);
        if (snapshot.hasData) {
          var data = snapshot.data;
          return ListView.builder(
            controller: _scrollController,
            itemCount: data.length,
            itemBuilder: (ctx, i) => PostWidget(
              key: Key(data[i].id),
              post: data[i],
            ),
          );
        }
        return Center(
          child: Text("No Posts Found"),
        );
      },
    );
  }
}
