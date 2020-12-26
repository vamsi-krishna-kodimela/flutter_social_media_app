import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media/screens/app_info_screen/app_info_screen.dart';
import 'package:social_media/screens/class_room_screen/class_room_screen.dart';
import 'package:social_media/screens/entertainment_screen/entertainment_Screen.dart';

import '../../constants.dart';
import '../ads_screen/ads_screen.dart';
import '../create_post_screen/create_post_screen.dart';
import '../friends_screen/friends_screen.dart';
import '../group_posts_screen/group_posts_screen.dart';
import '../main_screen.dart';
import '../messaging_list_screen/messaging_list_screen.dart';
import '../pages_screen/pages_screen.dart';
import '../posts_screen/posts_screen.dart';
import '../profile_screen/profile_screen.dart';
import '../search_screen/search_screen.dart';
import '../store_screen/store_screen.dart';
import '../../services/firebase_auth_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  int tab = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final _user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  _configureFirebaseListeners() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print("onMessage Called: $message");
    }, onResume: (Map<String, dynamic> message) async {
      print("onResume Called: $message");
    }, onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch Called: $message");
    });
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
  }

  void checkUserPresence() async {
    if (FirebaseAuth.instance.currentUser != null) {
      final databaseReference =
          FirebaseDatabase.instance.reference().child("status/${_user.uid}");
      databaseReference.set(1).then((value) {
        databaseReference.onDisconnect().set(0);
      });
      databaseReference.onValue.listen((event) {
        databaseReference.set(1).then((value) {
          databaseReference.onDisconnect().set(0);
        });
      });
    }
  }



  @override
  void initState() {
    super.initState();
    _configureFirebaseListeners();
    checkUserPresence();
    _firebaseMessaging.onTokenRefresh.listen((String fcmToken) {
      _firestore.collection("users").doc(_user.uid).update({
        "messageToken": FieldValue.arrayUnion([fcmToken]),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      backgroundColor: kBGColor,
      appBar: _buildAppBar(),
      drawer: _buildSidebar(),
      body: _widgetRetriver(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _widgetRetriver() {
    switch (tab) {
      case 1:
        return MessagingListScreen();
      case 2:
        return StoreScreen();
      case 3:
        return EntertainmentScreen();
      default:
        return PostsScreen();
    }
  }

  BottomAppBar _buildBottomAppBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: kDefaultPadding,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildBottomBarButton(0, FeatherIcons.home),
              buildBottomBarButton(1, FeatherIcons.messageSquare),
              SizedBox(width: kDefaultPadding * 3),
              buildBottomBarButton(2, Icons.storefront_outlined),
              buildBottomBarButton(3, Icons.local_fire_department_sharp),
            ],
          ),
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      elevation: 0.0,
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => CreatePostScreen()));
      },
      child: Icon(Icons.create_outlined),
      backgroundColor: kPrimaryColor,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        kAppName,
        style: TextStyle(
          color: kTextColor,
          fontFamily: GoogleFonts.lobster().fontFamily,
          fontSize: 26.0,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(FeatherIcons.search),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchScreen(),
              ),
            );
          },
        ),
        IconButton(icon: Icon(FeatherIcons.bell), onPressed: () {}),
      ],
      elevation: 0.0,
    );
  }

  Container buildBottomBarButton(int val, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            // color: (val == tab) ? kPrimaryColor : Colors.transparent,
            color: Colors.transparent,
            // width: 2,
          ),
        ),
      ),
      child: IconButton(
        onPressed: () {
          if (val == 3) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => EntertainmentScreen()));
            return;
          }
          if (tab != val) {
            setState(() {
              tab = val;
            });
          }
        },
        icon: Icon(
          icon,
          size: (val == tab) ? 30.0 : 24.0,
        ),
        color: (val == tab) ? kPrimaryColor : kTextColor,
      ),
    );
  }

  _buildSidebar() {
    return SafeArea(
      child: Drawer(
        child: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: 50.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.white,
                      Colors.white,
                      Colors.green
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 50.0,
                      ),
                      child: Image.asset("assets/logo.png"),
                    ),
                    Text(
                      "Connect & Engage with your Likeminds",
                      style: TextStyle(
                        color: Color(0xFF2a608c),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                          vertical: kDefaultPadding / 2),
                      title: Text(
                        _user.displayName.trim(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: kPrimaryColor,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ProfileScreen()));
                      },
                      leading: AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(kDefaultPadding),
                          child: FancyShimmerImage(
                            imageUrl: _user.photoURL,
                            boxFit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: kBGColor,
                  child: ListView(
                    padding: EdgeInsets.all(0.0),
                    children: [
                      Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              tab = 0;
                            });
                          },
                          leading: Icon(
                            FeatherIcons.home,
                            color: kPrimaryColor,
                          ),
                          title: Text(
                            "Home",
                            style: TextStyle(
                              color: kTextColor,
                            ),
                          ),
                        ),
                        elevation: 0.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 1.0),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 1.0),
                        elevation: 0.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => FriendsScreen(
                                      likedBy: [],
                                    )));
                          },
                          leading: Icon(
                            FeatherIcons.users,
                            color: kPrimaryColor,
                          ),
                          title: Text(
                            "Friends",
                            style: TextStyle(
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 1.0),
                        elevation: 0.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              tab = 2;
                            });
                          },
                          leading: Icon(
                            Icons.store,
                            color: kPrimaryColor,
                          ),
                          title: Text(
                            "Store",
                            style: TextStyle(
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 1.0),
                        elevation: 0.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pop();

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => ClassRoomScreen()),
                            );
                          },
                          leading: Icon(
                            FeatherIcons.bookOpen,
                            color: kPrimaryColor,
                          ),
                          title: Text(
                            "Classrooms",
                            style: TextStyle(
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 1.0),
                        elevation: 0.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              tab = 3;
                            });
                          },
                          leading: Icon(
                            Icons.local_fire_department_outlined,
                            color: kPrimaryColor,
                          ),
                          title: Text(
                            "Entertainment",
                            style: TextStyle(
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 1.0),
                        elevation: 0.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => GroupPostsScreen()));
                          },
                          leading: Icon(
                            FeatherIcons.flag,
                            color: kPrimaryColor,
                          ),
                          title: Text(
                            "Groups",
                            style: TextStyle(
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 1.0),
                        elevation: 0.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pop();

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => PagesScreen()));

                            // _scaffold.currentState.showSnackBar(SnackBar(content: Text("Page uder construction")));
                          },
                          leading: Icon(
                            FeatherIcons.layout,
                            color: kPrimaryColor,
                          ),
                          title: Text(
                            "Pages",
                            style: TextStyle(
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 1.0),
                        elevation: 0.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SearchScreen(),
                              ),
                            );
                          },
                          leading: Icon(
                            FeatherIcons.search,
                            color: kPrimaryColor,
                          ),
                          title: Text(
                            "Search",
                            style: TextStyle(
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 1.0),
                        elevation: 0.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pop();
                            _scaffold.currentState.showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Notifications Screen is under construction!"),
                              ),
                            );
                          },
                          leading: Icon(
                            FeatherIcons.bell,
                            color: kPrimaryColor,
                          ),
                          title: Text(
                            "Notifications",
                            style: TextStyle(
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 1.0),
                        elevation: 0.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => AdsScreen()));
                          },
                          leading: Icon(
                            FeatherIcons.package,
                            color: kPrimaryColor,
                          ),
                          title: Text(
                            "Promotions",
                            style: TextStyle(
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 1.0),
                        elevation: 0.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AppInfoScreen("about")));
                          },
                          title: Text(
                            "About",
                            style: TextStyle(color: kTextColor),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 0.0),
                        elevation: 0.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AppInfoScreen("privacy")));
                          },
                          title: Text(
                            "Privacy Policy",
                            style: TextStyle(color: kTextColor),
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 0.0),
                        elevation: 0.0,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AppInfoScreen("terms")));
                          },
                          title: Text(
                            "Terms & Conditions",
                            style: TextStyle(color: kTextColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: kWhite,
                child: Card(
                  color: kAccentColor.withAlpha(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  margin: EdgeInsets.only(top: 1.0),
                  elevation: 0.0,
                  child: ListTile(
                    onTap: () async {
                      await FirebaseAuthService().userSignout();
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => MainScreen()));
                    },
                    leading: Icon(
                      Icons.logout,
                      color: kAccentColor,
                    ),
                    title: Text(
                      "Logout",
                      style: TextStyle(
                        color: kAccentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
