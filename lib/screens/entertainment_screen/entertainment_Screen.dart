import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/entertainment_screen/components/audio_player_component.dart';
import 'package:social_media/screens/entertainment_upload_screen/entertainment_upload_screen.dart';

import '../../components/top_bar_option.dart';
import 'components/video_player_component.dart';

class EntertainmentScreen extends StatefulWidget {
  @override
  _EntertainmentScreenState createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  var currentOption = 0;

  void changeOption(val) {
    _hasMorePosts = true;
    _hasMoreAudios = true;
    _hasMoreVideos = true;
    _lastAudio = null;
    _lastVideo = null;
    _lastDocument = null;
    _allPagedVideos = List<List<QueryDocumentSnapshot>>();
    _allPagedAudio = List<List<QueryDocumentSnapshot>>();
    _allPagedResults = List<List<QueryDocumentSnapshot>>();
    setState(() {
      currentOption = val;
    });
  }

  ScrollController _scrollController = ScrollController();
  final int perPage = 4;
  String uid;
  bool _hasMorePosts = true;
  DocumentSnapshot _lastDocument;
  List<List<QueryDocumentSnapshot>> _allPagedResults =
      List<List<QueryDocumentSnapshot>>();

  //For videos Only section

  bool _hasMoreVideos = true;
  DocumentSnapshot _lastVideo;
  List<List<QueryDocumentSnapshot>> _allPagedVideos =
      List<List<QueryDocumentSnapshot>>();

  //For audio only section
  bool _hasMoreAudios = true;
  DocumentSnapshot _lastAudio;
  List<List<QueryDocumentSnapshot>> _allPagedAudio =
      List<List<QueryDocumentSnapshot>>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxScroll - currentScroll <= delta) if (currentOption == 0)
        _requestPosts();
      else if (currentOption == 1)
        _requestVideos();
      else
        _requestVideos();
    });
  }

  final StreamController<List<QueryDocumentSnapshot>> _postsController =
      StreamController<List<QueryDocumentSnapshot>>.broadcast();

  final StreamController<List<QueryDocumentSnapshot>> _videosController =
      StreamController<List<QueryDocumentSnapshot>>.broadcast();
  final StreamController<List<QueryDocumentSnapshot>> _audiosController =
      StreamController<List<QueryDocumentSnapshot>>.broadcast();

  final _postsCollectionReference = FirebaseFirestore.instance
      .collection("entertainment")
      .orderBy("postedOn", descending: true);
  final _videosCollectionReference = FirebaseFirestore.instance
      .collection("entertainment")
      .where("type", isEqualTo: 0)
      .orderBy("postedOn", descending: true);
  final _audiosCollectionReference = FirebaseFirestore.instance
      .collection("entertainment")
      .where("type", isEqualTo: 1)
      .orderBy("postedOn", descending: true);

  Stream listenToPostsRealTime() {
    _requestPosts();

    return _postsController.stream;
  }

  Stream listenToVideosRealTime() {
    _requestVideos();
    return _videosController.stream;
  }

  Stream listenToAudiosRealTime() {
    _requestAudios();
    return _audiosController.stream;
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

  void _requestVideos() {
    var pagePostsQuery = _videosCollectionReference.limit(perPage);
    if (_lastVideo != null)
      pagePostsQuery = pagePostsQuery.startAfterDocument(_lastVideo);

    var currentRequestIndex = _allPagedVideos.length;

    pagePostsQuery.snapshots().listen((postsSnapshot) {
      if (postsSnapshot.docs.isNotEmpty) {
        var posts = postsSnapshot.docs;
        var pageExists = currentRequestIndex < _allPagedVideos.length;

        if (pageExists) {
          _allPagedVideos[currentRequestIndex] = posts;
        } else {
          _allPagedVideos.add(posts);
        }

        var allPosts = _allPagedVideos.fold<List<QueryDocumentSnapshot>>(
            List<QueryDocumentSnapshot>(),
            (initialValue, pageItems) => initialValue..addAll(pageItems));

        _videosController.add(allPosts);

        // Save the last document from the results only if it's the current last page
        if (currentRequestIndex == _allPagedVideos.length - 1) {
          _lastVideo = postsSnapshot.docs.last;
        }
        // Determine if there's more posts to request
        _hasMoreVideos = (posts.length == perPage);
      }
    });
  }

  void _requestAudios() {
    var pagePostsQuery = _audiosCollectionReference.limit(perPage);
    if (_lastAudio != null)
      pagePostsQuery = pagePostsQuery.startAfterDocument(_lastAudio);

    var currentRequestIndex = _allPagedAudio.length;

    pagePostsQuery.snapshots().listen((postsSnapshot) {
      if (postsSnapshot.docs.isNotEmpty) {
        var posts = postsSnapshot.docs;
        var pageExists = currentRequestIndex < _allPagedAudio.length;

        if (pageExists) {
          _allPagedAudio[currentRequestIndex] = posts;
        } else {
          _allPagedAudio.add(posts);
        }

        var allPosts = _allPagedAudio.fold<List<QueryDocumentSnapshot>>(
            List<QueryDocumentSnapshot>(),
            (initialValue, pageItems) => initialValue..addAll(pageItems));

        _audiosController.add(allPosts);

        // Save the last document from the results only if it's the current last page
        if (currentRequestIndex == _allPagedAudio.length - 1) {
          _lastAudio = postsSnapshot.docs.last;
        }
        // Determine if there's more posts to request
        _hasMoreAudios = (posts.length == perPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Entertainment",
          style: TextStyle(
            color: kTextColor,
            fontFamily: GoogleFonts.lobster().fontFamily,
            fontSize: 26.0,
          ),
        ),
        elevation: 0.0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EntertainmentUploadScreen()));
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: kDefaultPadding*2),
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TopBarOption(
                    isActive: currentOption == 0,
                    option: "All",
                    onPress: changeOption,
                    optionNum: 0,
                  ),
                  TopBarOption(
                    isActive: currentOption == 1,
                    option: "Video",
                    onPress: changeOption,
                    optionNum: 1,
                  ),
                  TopBarOption(
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
              child: StreamBuilder<List<QueryDocumentSnapshot>>(
                  stream: (currentOption == 0)
                      ? listenToPostsRealTime()
                      : (currentOption == 1)
                          ? listenToVideosRealTime()
                          : listenToAudiosRealTime(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    if (!snapshot.hasData)
                      return Center(
                        child: Text("No content found.."),
                      );
                    List<QueryDocumentSnapshot> _data = snapshot.data;
                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(kDefaultPadding),
                      itemCount: _data.length,
                      itemBuilder: (ctx, i) {
                        Map<String, dynamic> resourceData = _data[i].data();
                        if (resourceData["type"] == 0) {
                          return VideoPlayerComponent(
                            data: resourceData,
                            key: Key(_data[i].id),
                            reference: _data[i].reference,
                          );
                        }
                        // return Text("Audio");
                        return AudioPlayerComponent(
                          reference: _data[i].reference,
                          key: Key(_data[i].id),
                          data: _data[i].data(),
                        );
                      },
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
