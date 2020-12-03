import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';

class AppInfoScreen extends StatelessWidget {
  final String type;
  final _firestore = FirebaseFirestore.instance;

  AppInfoScreen(this.type);

  @override
  Widget build(BuildContext context) {
    String name = "";
    String doc = "";
    switch (type) {
      case "about":
        name = "About Us";
        doc = "about";
        break;
      case "terms":
        name = "Terms of Use";
        doc = "terms_conditions";
        break;
      case "privacy":
        name = "Privacy Policy";
        doc = "privacy_policy";
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection("app_info").doc(doc).get(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          final data = snapshot.data.data();
          final String info = data["info"];

          return Column(
            children: [
              Image.asset(
                "assets/logo.png",
                width: MediaQuery.of(context).size.width / 2,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: kDefaultPadding * 2,
                        horizontal: kDefaultPadding*2),
                    child: Text(
                      info,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
