import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media/screens/single_user_screen/single_user_screen.dart';
import '../../constants.dart';

class FriendsScreen extends StatelessWidget {
  List<String> likedBy;
  String type= "Friends";

  FriendsScreen({Key key, this.likedBy,this.type="Friends"}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    final _uid = FirebaseAuth.instance.currentUser.uid;
    var _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          type,
          style: TextStyle(
            color: kTextColor,
            fontFamily: GoogleFonts.lobster().fontFamily,
            fontSize: 26.0,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(

        stream: _firestore.collection("users").doc(_uid).snapshots(),

        builder: (ctx,snapshot){
          if(snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          final data = snapshot.data.data();
          final Map<String,dynamic> friends = data["friends"];
          friends.removeWhere((key, value) => value!=3);
          if(likedBy.length==0)likedBy = friends.keys.toList();
          return ListView.builder(
            itemBuilder: (ctx, i) {
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection("users").doc(likedBy[i]).get(),
                builder: (ctx, snapshot) {
                  if (snapshot.data == null) {
                    return ListTile(
                      leading: Container(
                        width: _size.width * 0.1,
                        height: _size.width * 0.1,
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(_size.width * 0.1),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300],
                            highlightColor: Colors.grey[100],
                            child: Container(
                              width: _size.width * 0.1,
                              height: _size.width * 0.1,
                              color: kAccentColor,
                            ),
                          ),
                        ),
                      ),
                      title: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[100],
                        child: Container(
                          width: _size.width * 0.2,
                          height: 16.0,
                          color: kAccentColor,
                        ),
                      ),

                    );
                  }
                  final _userInfo = snapshot.data.data();
                  return _AuthorDetails(
                    size: _size,
                    userInfo: _userInfo,
                    uid: snapshot.data.id,
                  );
                },
              );
            },
            itemCount: likedBy.length,
          );
        },

      ),
    );
  }
}


class _AuthorDetails extends StatelessWidget {
  const _AuthorDetails({
    Key key,
    @required Size size,
    @required Map<String, dynamic> userInfo,
    @required this.uid,
  })  : _size = size,
        _userInfo = userInfo,
        super(key: key);

  final Size _size;
  final Map<String, dynamic> _userInfo;
  final String uid;

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SingleUserScreen(uid),
            ),
          );
        },
        leading: Container(
          width: _size.width * 0.1,
          height: _size.width * 0.1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(kDefaultPadding),

            child: FancyShimmerImage(
              imageUrl: _userInfo["photoUrl"],
              boxFit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          _userInfo["name"],
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}