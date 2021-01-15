import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media/components/empty_state_component.dart';
import 'package:social_media/screens/single_user_screen/single_user_screen.dart';
import '../../constants.dart';

class FriendsScreen extends StatefulWidget {
  List<String> likedBy;
  String uid;
  String type = "Friends";

  FriendsScreen({Key key, this.likedBy,this.uid, this.type = "Friends"})
      : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String _chosenValue="Friends";
  final uid = FirebaseAuth.instance.currentUser.uid;
  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    final _uid = (widget.uid!=null)?widget.uid:uid;
    var _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type,
          style: TextStyle(
            color: kTextColor,
            fontFamily: GoogleFonts.lobster().fontFamily,
            fontSize: 26.0,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("users").doc(_uid).snapshots(),
        builder: (ctx, snapshot) {
          List<String> _people=widget.likedBy;
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          final data = snapshot.data.data();
          if (!snapshot.data.exists && widget.type=="Friends")
            return Center(
              child: EmptyStateComponent("Start Making Friends"),
            );
          final Map<String, dynamic> friends = data["friends"];
          if(_chosenValue== 'Friends')friends.removeWhere((key, value) => value != 3);
          if(_chosenValue== 'Requests Received')friends.removeWhere((key, value) => value != 1);
          if(_chosenValue == 'Requests Sent')friends.removeWhere((key, value) => value != 0);
          if ( widget.type=="Friends") _people = friends.keys.toList();
          if (_people.length == 0)
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if(uid==_uid && widget.type=="Friends")_buildDropdownButton(),
                Expanded(
                  child: Center(
                    child: EmptyStateComponent("Start Making Friends"),
                  ),
                ),
              ],
            );
          return Column(

            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if(uid==_uid  && widget.type=="Friends")_buildDropdownButton(),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (ctx, i) {
                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          _firestore.collection("users").doc(_people[i]).get(),
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
                        if(!snapshot.data.exists)
                          return Container();
                        return _AuthorDetails(
                          size: _size,
                          userInfo: _userInfo,
                          uid: snapshot.data.id,
                        );
                      },
                    );
                  },
                  itemCount: _people.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  DropdownButton<String> _buildDropdownButton() {
    return DropdownButton<String>(
                value: _chosenValue,
                items: <String>['Friends', 'Requests Received', 'Requests Sent',]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),

                  );
                }).toList(),

                onChanged: (String value) {
                  setState(() {
                    _chosenValue = value;
                  });
                },

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
