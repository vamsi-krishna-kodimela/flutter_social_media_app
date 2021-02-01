import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:social_media/constants.dart';
import '../profile_screen/components/user_feed.dart';

class SingleUserScreen extends StatelessWidget {
  final String uid;

  const SingleUserScreen(this.uid);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        title:Row(
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
            icon: Icon(FeatherIcons.share2),
            onPressed: () {
              Share.share("https://friendzit.in/user/$uid");
            },
          ),
        ],
      ),
      body: Container(
        width: _size.width,
        child: UserFeed(uid),
      ),
    );
  }
}
