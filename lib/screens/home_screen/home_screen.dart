//Dart imports
import 'dart:async';
import 'dart:convert';

//Flutter Package imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

//Custom imports
import '../../constants.dart';
import '../ads_screen/ads_screen.dart';
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
import '../../utils.dart';
import '../../providers/chats_provider.dart';
import '../app_info_screen/app_info_screen.dart';
import '../chat_screen/chat_screen.dart';
import '../class_room_screen/class_room_screen.dart';
import '../entertainment_screen/entertainment_Screen.dart';
import '../notifications_screen/notifications_screen.dart';
import '../pages_screen/components/page_posts_home.dart';
import '../single_group_post/single_group_post.dart';
import '../single_group_screen/single_group_screen.dart';
import '../single_page_post/single_page_post.dart';
import '../single_page_screen/single_page_screen.dart';
import '../single_user_post/single_user_post.dart';
import '../single_user_screen/single_user_screen.dart';

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
  dynamic _provider;

  StreamSubscription _sub;

  _configureFirebaseListeners() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      final _data = message["data"];
      if (_data["type"] == "USER_CHAT" && tab != 1)
        _provider.addChatRoom(_data["friendId"]);
    }, onResume: (Map<String, dynamic> message) async {
      final _data = message["data"];
      final _friend = json.decode(_data["friendData"]);
      final _friendId = _data["friendId"];
      if (_data["type"] == "USER_CHAT") {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatScreen(_friend, _friendId)));
        });
      }
    }, onLaunch: (Map<String, dynamic> message) async {
      final _data = message["data"];
      final _friend = json.decode(_data["friendData"]);
      final _friendId = _data["friendId"];
      if (_data["type"] == "USER_CHAT") {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatScreen(_friend, _friendId)));
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notificationNavigator(
              id: _data["id"],
              ctx: context,
              type: _data["type"],
              name: _data["name"]);
        });
      }
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
    initPlatformStateForStringUniLinks();

    checkUserPresence();
    _firebaseMessaging.onTokenRefresh.listen((String fcmToken) {
      _firestore.collection("users").doc(_user.uid).update({
        "messageToken": FieldValue.arrayUnion([fcmToken]),
      });
    });
  }

  @override
  void dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _provider = Provider.of<ChatsProvider>(context, listen: false);
    return Scaffold(
      key: _scaffold,
      backgroundColor: kBGColor,
      appBar: _buildAppBar(),
      drawer: _buildSidebar(),
      body: _widgetRetriver(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _widgetRetriver() {
    switch (tab) {
      // case 1:
      // return MessagingListScreen();
      case 2:
        return StoreScreen();
      case 4:
        return _profileWidgetFunction();
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
              buildBottomBarButton(1, FeatherIcons.search),
              buildBottomBarButton(2, Icons.storefront_outlined),
              buildBottomBarButton(3, Icons.local_fire_department_sharp),
              buildBottomBarButton(4, FeatherIcons.user),
            ],
          ),
        ),
      ),
    );
  }

  // FloatingActionButton _buildFloatingActionButton() {
  //   return FloatingActionButton(
  //     elevation: 0.0,
  //     onPressed: () {
  //       Navigator.of(context)
  //           .push(MaterialPageRoute(builder: (_) => CreatePostScreen()));
  //     },
  //     child: Icon(Icons.create_outlined),
  //     backgroundColor: kPrimaryColor,
  //   );
  // }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/icon.png",
            height: 40.0,
            fit: BoxFit.fitHeight,
          ),
          SizedBox(
            width: kDefaultPadding,
          ),
          Text(
            kAppName,
            style: TextStyle(
              color: kTextColor,
              fontFamily: GoogleFonts.lobster().fontFamily,
              fontSize: 26.0,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(FeatherIcons.bell),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NotificationsScreen(),
              ),
            );
          },
        ),
      ],
      elevation: 0.0,
    );
  }

  Container buildBottomBarButton(int val, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.transparent,
            // width: 2,
          ),
        ),
      ),
      child: Consumer<ChatsProvider>(
        builder: (ctx, data, __) => Stack(
          children: [
            IconButton(
              onPressed: () {
                if (val == 3) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => EntertainmentScreen()));
                  return;
                }
                if (val == 1) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => SearchScreen()));
                  return;
                }
                // if (val == 4) {
                //   Navigator.of(context)
                //       .push(MaterialPageRoute(builder: (_) => ProfileScreen()));
                //   return;
                // }

                if (tab != val) {
                  setState(() {
                    tab = val;
                  });
                }
              },
              icon: Icon(
                icon,
                size: (val == tab) ? 26.0 : 24.0,
              ),
              color: (val == tab) ? kPrimaryColor : kTextColor.withAlpha(200),
            ),
            if (data.getCurrentChatsCount() != 0 && val == 1)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: kAccentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data.getCurrentChatsCount().toString(),
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
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
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: kDefaultPadding,
                            vertical: kDefaultPadding / 2,
                          ),
                          title: Text(
                            _user.displayName.trim(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: kPrimaryColor,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ProfileScreen()));
                          },
                          leading: AspectRatio(
                            aspectRatio: 1.0,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(kDefaultPadding),
                              child: FancyShimmerImage(
                                imageUrl: _user.photoURL,
                                boxFit: BoxFit.cover,
                              ),
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
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).pop();
                            if (tab != 0)
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MessagingListScreen(),
                              ),
                            );
                          },
                          leading: Icon(
                            FeatherIcons.messageSquare,
                            color: kPrimaryColor,
                          ),
                          title: Text(
                            "Messages",
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
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => EntertainmentScreen()));
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
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => NotificationsScreen()));
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
                      // Card(
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(0.0),
                      //   ),
                      //   margin: EdgeInsets.only(top: 1.0),
                      //   elevation: 0.0,
                      //   child: ListTile(
                      //     onTap: () {
                      //       Navigator.of(context).push(
                      //           MaterialPageRoute(builder: (_) => AdsScreen()));
                      //     },
                      //     leading: Icon(
                      //       FeatherIcons.package,
                      //       color: kPrimaryColor,
                      //     ),
                      //     title: Text(
                      //       "Promotions",
                      //       style: TextStyle(
                      //         color: kTextColor,
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


  _profileWidgetFunction(){
    return Container(
      child: ListView(
        padding: EdgeInsets.all(0.0),
        children: [
          Card(
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
                vertical: kDefaultPadding / 2,
              ),
              title: Text(
                _user.displayName.trim(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                  color: kPrimaryColor,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ProfileScreen()));
              },
              leading: AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(kDefaultPadding),
                  child: FancyShimmerImage(
                    imageUrl: _user.photoURL,
                    boxFit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            margin: EdgeInsets.only(top: 1.0),
          ),
          SizedBox(height: 8.0),
          Card(
            child: ListTile(
              onTap: () {
                if (tab != 0)
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
          SizedBox(height: 2.0),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            margin: EdgeInsets.only(top: 1.0),
            elevation: 0.0,
            child: ListTile(
              onTap: () {
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
          SizedBox(height: 2.0),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            margin: EdgeInsets.only(top: 1.0),
            elevation: 0.0,
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MessagingListScreen(),
                  ),
                );
              },
              leading: Icon(
                FeatherIcons.messageSquare,
                color: kPrimaryColor,
              ),
              title: Text(
                "Messages",
                style: TextStyle(
                  color: kTextColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.0),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            margin: EdgeInsets.only(top: 1.0),
            elevation: 0.0,
            child: ListTile(
              onTap: () {
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
          SizedBox(height: 2.0),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            margin: EdgeInsets.only(top: 1.0),
            elevation: 0.0,
            child: ListTile(
              onTap: () {
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
          SizedBox(height: 2.0),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            margin: EdgeInsets.only(top: 1.0),
            elevation: 0.0,
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => EntertainmentScreen()));
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
          SizedBox(height: 2.0),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            margin: EdgeInsets.only(top: 1.0),
            elevation: 0.0,
            child: ListTile(
              onTap: () {
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
          SizedBox(height: 2.0),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            margin: EdgeInsets.only(top: 1.0),
            elevation: 0.0,
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PagesScreen()));
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
          SizedBox(height: 2.0),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            margin: EdgeInsets.only(top: 1.0),
            elevation: 0.0,
            child: ListTile(
              onTap: () {
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
          SizedBox(height: 2.0),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            margin: EdgeInsets.only(top: 1.0),
            elevation: 0.0,
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => NotificationsScreen()));
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
          SizedBox(height: 2.0),
          // Card(
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(0.0),
          //   ),
          //   margin: EdgeInsets.only(top: 1.0),
          //   elevation: 0.0,
          //   child: ListTile(
          //     onTap: () {
          //       Navigator.of(context).push(
          //           MaterialPageRoute(builder: (_) => AdsScreen()));
          //     },
          //     leading: Icon(
          //       FeatherIcons.package,
          //       color: kPrimaryColor,
          //     ),
          //     title: Text(
          //       "Promotions",
          //       style: TextStyle(
          //         color: kTextColor,
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
          SizedBox(height: 1.5),
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
          SizedBox(height: 1.5),
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
    );
  }

  initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream
    _sub = getLinksStream().listen((String link) {
      if (!mounted) return;
      try {
        if (link != null) print(link);
      } on FormatException {}
    }, onError: (err) {
      if (!mounted) return;
      print('Failed to get latest link: $err.');
    });

    // Attach a second listener to the stream
    getLinksStream().listen((String link) {
      _deepLinkParser(link);
    }, onError: (err) {
      print('got err: $err');
    });

    // Get the latest link
    String initialLink;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialLink = await getInitialLink();
      print('initial link: $initialLink');
    } on PlatformException {
      initialLink = 'Failed to get initial link.';
    } on FormatException {
      initialLink = 'Failed to parse the initial link as Uri.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    if (!mounted) return;
    if (initialLink != null) _deepLinkParser(initialLink);
  }

  _deepLinkParser(String link) {
    Uri _link = Uri.parse(link);
    List<String> _params = _link.path.split("/");
    _params.remove("");
    switch (_params[0]) {
      case "posts":
        if (_params.length == 2)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SingleUserPost(_params[1]),
            ),
          );
        break;
      case "group":
        if (_params.length == 2)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SingleGroupScreen(_params[1]),
            ),
          );
        else
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GroupPostsScreen(),
            ),
          );

        break;
      case "page":
        if (_params.length == 2)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SinglePageScreen(
                pageId: _params[1],
              ),
            ),
          );
        else
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PagePostsScreen(),
            ),
          );
        break;
      case "pg":
        if (_params.length == 2)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SinglePagePost(_params[1]),
            ),
          );
        else
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PagePostsScreen(),
            ),
          );
        break;
      case "grp":
        if (_params.length == 2)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SingleGroupPost(_params[1]),
            ),
          );
        else
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GroupPostsScreen(),
            ),
          );
        break;
      case "user":
        if (_params.length == 2)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SingleUserScreen(_params[1]),
            ),
          );
        break;
    }
  }
}
