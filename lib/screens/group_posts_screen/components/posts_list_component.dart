import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/group_post_widget_component/group_post_widget_component.dart';

class PostsListComponent extends StatefulWidget {
  final gid;
  final groups;

  const PostsListComponent({this.groups, this.gid});

  @override
  _PostsListComponentState createState() => _PostsListComponentState();
}

class _PostsListComponentState extends State<PostsListComponent> {
  ScrollController _scrollController = ScrollController();
  final int perPage = 20;
  String uid;
  bool _hasMorePosts = true;
  DocumentSnapshot _lastDocument;
  List<List<QueryDocumentSnapshot>> _allPagedResults =
      List<List<QueryDocumentSnapshot>>();

  popListItem() {
    if (_allPagedResults.length == 1)
      setState(() {
        _allPagedResults = List<List<QueryDocumentSnapshot>>();
      });
  }

  @override
  void initState() {
    super.initState();

    if (widget.gid != null)
      _postsCollectionReference = FirebaseFirestore.instance
          .collection("group_posts")
          .where("group", isEqualTo: widget.gid)
          .orderBy("postedOn", descending: true);
    else
      _postsCollectionReference = FirebaseFirestore.instance
          .collection("group_posts")
          .orderBy("postedOn", descending: true);
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
      .collection("group_posts")
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

        if (widget.gid == null)
          _postsController.add(allPosts
              .where(
                  (element) => widget.groups.contains(element.data()["group"]))
              .toList());
        else
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
    final _firestore = FirebaseFirestore.instance;
    return FutureBuilder(
      future: _firestore
          .collection("groups")
          .where("members", arrayContains: uid)
          .get(),
      builder: (ctx, data) {
        if (data.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(),
          );

        return StreamBuilder<List<QueryDocumentSnapshot>>(
          stream: listenToPostsRealTime(),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: Text("No Posts found"),
              );
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
                  itemBuilder: (ctx, i) => GroupPostWidgetComponent(
                    key: Key(data[i].id),
                    post: data[i],
                    function: popListItem,
                  ),
                );
              return Center(
                child: Text("No Posts Found"),
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
