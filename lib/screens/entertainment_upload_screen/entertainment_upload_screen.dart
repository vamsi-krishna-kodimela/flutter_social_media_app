import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';

class EntertainmentUploadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        title: Text("Uploader"),
        elevation: 0.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          color: kBGColor,
        ),
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text("Hello"),
              ),
            ),
            Container(
              width: double.infinity,
              color: kAccentColor,
              child: FlatButton(
                padding: EdgeInsets.all(20.0),
                onPressed: () {},
                child: Text(
                  "Publish",
                  style: TextStyle(
                    color: kWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                color: kAccentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
