import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/single_page_screen/single_page_screen.dart';
import '../single_group_screen/single_group_screen.dart';

import '../../constants.dart';

class PagesSearchScreen extends StatefulWidget {
  @override
  _PagesSearchScreenState createState() => _PagesSearchScreenState();
}

class _PagesSearchScreenState extends State<PagesSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CollectionReference _firestore =
  FirebaseFirestore.instance.collection("pages");
  final uid = FirebaseAuth.instance.currentUser.uid;
  final int perPage = 10;
  bool hasMoreResults = true;

  List<QueryDocumentSnapshot> _results = [];
  QueryDocumentSnapshot _lastResult;

  void getResults() async {
    _results = [];
    var key = _searchController.value.text.toLowerCase();

    var query = _firestore.where("keys", arrayContains: key).limit(perPage);

    var res = await query.get();
    _results = res.docs;

    if (_results.length != 0) _lastResult = _results[_results.length - 1];
    if (_results.length < perPage) hasMoreResults = false;
    _results.removeWhere((element) => element.id == uid);
    if (this.mounted) setState(() {});
  }

  void getMoreResults() async {
    var key = _searchController.value.text.toLowerCase();

    var query = _firestore
        .where("keys", arrayContains: key)
        .startAfterDocument(_lastResult)
        .limit(perPage);
    var res = await query.get();
    _results.addAll(res.docs);

    if (_results.length != 0) _lastResult = _results[_results.length - 1];
    if (res.docs.length < perPage) hasMoreResults = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      hasMoreResults = true;
      if (_searchController.value.text.length > 0) {
        getResults();
      } else {
        setState(() {
          _results = [];
        });
      }
    });

    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;
      if (maxScroll - currentScroll <= delta && hasMoreResults)
        getMoreResults();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          "Search For Pages",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: kTextColor

          ),
        ),
      ),
      body: Column(
        children: [
          SearchBarWidget(searchController: _searchController),
          Expanded(
            child: (_results.length == 0)
                ? Text("No Results Found")
                : ListView.builder(
              controller: _scrollController,
              itemBuilder: (ctx, i) {
                Map<String, dynamic> _data = _results[i].data();
                return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      contentPadding: EdgeInsets.all(kDefaultPadding),
                      onTap: () {

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SinglePageScreen(
                              pageId: _data[i].id,
                              pageName: _data[i].data()["name"],
                            ),
                          ),
                        );
                      },
                      title: Text(
                        _data["name"],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: kTextColor,
                            fontWeight: FontWeight.w600),
                      ),
                      leading: Container(
                        width: kDefaultPadding * 6,
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(kDefaultPadding),
                          child: FancyShimmerImage(
                            imageUrl: _data["pic"],
                            boxFit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: _results.length,
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    Key key,
    @required TextEditingController searchController,
  })  : _searchController = searchController,
        super(key: key);

  final TextEditingController _searchController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: kDefaultPadding * 2,
        vertical: kDefaultPadding,
      ),
      padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(kDefaultPadding),
        color: kWhite,
        boxShadow: [
          BoxShadow(
            color: kGrey,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Search for Pages",
          suffixIcon: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search_outlined,
              color: kPrimaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
