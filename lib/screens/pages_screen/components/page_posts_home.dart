import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../page_post_list/components/page_post_widget.dart';

class PagePostsScreen extends StatefulWidget {
  @override
  _PagePostsScreenState createState() => _PagePostsScreenState();
}

class _PagePostsScreenState extends State<PagePostsScreen> {
  ScrollController _scrollController = ScrollController();
  final int perPage = 20;
  final String uid = FirebaseAuth.instance.currentUser.uid;
  bool _hasMorePosts = true;
  DocumentSnapshot _lastDocument;
  List<List<QueryDocumentSnapshot>> _allPagedResults =
      List<List<QueryDocumentSnapshot>>();
  List<String> _frnds = [];
  final _uid = FirebaseAuth.instance.currentUser.uid;

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
      .collection("page_posts")
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
          return _frnds.contains(_data["page"]);
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
    return FutureBuilder<QuerySnapshot>(
      future: _firestore
          .collection("pages")
          .where("followers", arrayContains: _uid)
          .get(),
      builder: (_, info) {
        if (info.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(),
          );

        final _data = info.data.docs;

        for (var j in _data) {
          _frnds.add(j.id);
        }
        if (_frnds.length == 0)
          return Center(
            child: Text("Follow pages to see their posts."),
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
                  itemCount: data.length,
                  itemBuilder: (ctx, i) => PagePostWidget(
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
      },
    );
  }
}
