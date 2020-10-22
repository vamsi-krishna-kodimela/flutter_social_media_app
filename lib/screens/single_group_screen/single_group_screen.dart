import 'package:flutter/material.dart';

class SingleGroupScreen extends StatelessWidget {
  final String gid;
  final Map<String,dynamic> gData;

  const SingleGroupScreen(this.gid,this.gData);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          gData["name"],
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
