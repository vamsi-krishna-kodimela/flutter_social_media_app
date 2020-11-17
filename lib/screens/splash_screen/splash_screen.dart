import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var duration = new Duration(seconds: 3);
    return new Timer(duration, () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
    });
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      height: MediaQuery.of(context).size.height,
      child: Image.asset("assets/splash.png",fit: BoxFit.fitHeight,),
    );
  }
}
