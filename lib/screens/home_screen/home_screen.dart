import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/create_post_screen/create_post_screen.dart';
import 'package:social_media/screens/entertainment_screen/entertainment_Screen.dart';
import 'package:social_media/screens/group_posts_screen/group_posts_screen.dart';
import 'package:social_media/screens/main_screen.dart';
import 'package:social_media/screens/messaging_list_screen/messaging_list_screen.dart';
import 'package:social_media/screens/posts_screen/posts_screen.dart';
import 'package:social_media/screens/profile_screen/profile_screen.dart';
import 'package:social_media/screens/search_screen/search_screen.dart';
import 'package:social_media/services/firebase_auth_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  int tab = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _configureFirebaseListeners() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print("onMessage Called: $message");
    }, onResume: (Map<String, dynamic> message) async {
      print("onResume Called: $message");
    }, onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch Called: $message");
    });
  }

  void checkUserPresence() async {
    if (FirebaseAuth.instance.currentUser != null) {
      var uid = FirebaseAuth.instance.currentUser.uid;
      final databaseReference =
          FirebaseDatabase.instance.reference().child("status/$uid");
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      backgroundColor: kBGColor,
      appBar: _buildAppBar(),
      drawer: _buildSidebar(),
      body: Stack(
        children: [
          Container(
            color: kPrimaryColor,
          ),
          Container(
            decoration: BoxDecoration(
              color: kBGColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15.0),
              ),
            ),
          ),
          ClipRRect(
            child: _widgetRetriver(),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15.0),
            ),
          ),
        ],
      ),
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
        return Center(child: Text("This Page is under Construction"));
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildBottomBarButton(0, Icons.home_outlined),
              buildBottomBarButton(1, Icons.chat_bubble_outline),
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
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_outlined),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchScreen(),
              ),
            );
          },
        ),
        IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        IconButton(
            icon: Icon(Icons.person_outline_rounded),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => ProfileScreen()));
            }),
      ],
      elevation: 0.0,
    );
  }

  Container buildBottomBarButton(int val, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: (val == tab) ? kPrimaryColor : Colors.transparent,
            width: 2,
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
          setState(() {
            tab = val;
          });
        },
        icon: Icon(icon),
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
                padding: EdgeInsets.symmetric(
                  vertical: 50.0,
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
                            setState(() {
                              tab = 0;
                            });
                            Navigator.of(context).pop();
                          },
                          leading: Icon(
                            Icons.home_outlined,
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
                            _scaffold.currentState.showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Classrooms Screen is under construction!"),
                              ),
                            );
                          },
                          leading: Icon(
                            Icons.class__outlined,
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
                            _scaffold.currentState.showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Entertainment Screen is under construction!"),
                              ),
                            );
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
                            Navigator.of(context).push(MaterialPageRoute(builder: (_)=>GroupPostsScreen()));
                          },
                          leading: Icon(
                            Icons.flag_outlined,
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
                            _scaffold.currentState.showSnackBar(
                              SnackBar(
                                content:
                                    Text("Pages Screen is under construction!"),
                              ),
                            );
                          },
                          leading: Icon(
                            Icons.chrome_reader_mode,
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
                            Icons.search_outlined,
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
                            Icons.notifications,
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
                      // Container(
                      //   color: kWhite,
                      //   child: Card(
                      //     color: kAccentColor.withAlpha(50),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(0.0),
                      //     ),
                      //     margin: EdgeInsets.only(top: 1.0),
                      //     elevation: 0.0,
                      //     child: ListTile(
                      //       onTap: () async {
                      //         await FirebaseAuthService().userSignout();
                      //         Navigator.pop(context);
                      //         Navigator.of(context).pushReplacement(
                      //             MaterialPageRoute(
                      //                 builder: (_) => MainScreen()));
                      //       },
                      //       leading: Icon(
                      //         Icons.logout,
                      //         color: kAccentColor,
                      //       ),
                      //       title: Text(
                      //         "Logout",
                      //         style: TextStyle(
                      //           color: kAccentColor,
                      //           fontWeight: FontWeight.w600,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        margin: EdgeInsets.only(top: 1.0),
                        elevation: 0.0,
                        child: ListTile(
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
