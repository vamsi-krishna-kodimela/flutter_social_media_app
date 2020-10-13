import 'package:flutter/material.dart';
import '../../constants.dart';

class LikesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Likes",
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Text("Likes"),
    );
  }
}
