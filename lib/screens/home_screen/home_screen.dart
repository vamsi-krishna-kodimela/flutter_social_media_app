import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/create_post_screen/create_post_screen.dart';
import 'package:social_media/screens/messaging_list_screen/messaging_list_screen.dart';
import 'package:social_media/screens/posts_screen/posts_screen.dart';
import 'package:social_media/screens/profile_screen/profile_screen.dart';
import 'package:social_media/screens/search_screen/search_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  int tab = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _getToken(){
    _firebaseMessaging.getToken().then((token){
      print("Token: $token");
    });
  }

  _configureFirebaseListeners(){
    _firebaseMessaging.configure(

      onMessage: (Map<String, dynamic> message) async{
        print("onMessage Called: $message");

      },
        onResume: (Map<String, dynamic> message) async{
          print("onResume Called: $message");

        },
        onLaunch: (Map<String, dynamic> message) async{
          print("onLaunch Called: $message");

        }
    );

  }

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      backgroundColor: kBGColor,
      appBar: _buildAppBar(),
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
        return Text("Stores");
      case 3:
        return ProfileScreen();
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
              buildBottomBarButton(3, Icons.person_outline),
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
        )),
      ),
      child: IconButton(
        onPressed: () {
          setState(() {
            tab = val;
          });
        },
        icon: Icon(icon),
        color: (val == tab) ? kPrimaryColor : kTextColor,
      ),
    );
  }
}
