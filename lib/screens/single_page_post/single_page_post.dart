import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media/screens/page_post_list/components/page_post_widget.dart';

import '../../constants.dart';

class SinglePagePost extends StatelessWidget {
  final String pId;

  const SinglePagePost(this.pId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          kAppName,
          style: TextStyle(
            color: kTextColor,
            fontFamily: GoogleFonts.lobster().fontFamily,
            fontSize: 26.0,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("page_posts")
            .doc(pId)
            .snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          final data = snapshot.data;
          if (!data.exists)
            return Center(
              child: Column(
                children: [
                  Image.asset("assets/empty_state.png",fit: BoxFit.fitWidth, width: MediaQuery.of(context).size.width*0.7,),
                  Text(
                    "POST NOT FOUND!",
                    style: TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                ],
              ),
            );
          return SingleChildScrollView(child: PagePostWidget(post: data,key: Key(data.id),));
        },
      ),
    );
  }
}
