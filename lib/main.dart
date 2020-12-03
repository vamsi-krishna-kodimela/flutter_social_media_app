import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media/screens/splash_screen/splash_screen.dart';

import './constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RootApp());
}

class RootApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      theme: ThemeData(
        fontFamily: GoogleFonts.nunitoSans().fontFamily,
        scaffoldBackgroundColor: kBGColor,
        primaryColor: kPrimaryColor,
        accentColor: kAccentColor,
        appBarTheme: AppBarTheme(
          color: Colors.transparent,
          brightness: Brightness.light,
          elevation: 0.0,
          iconTheme: IconThemeData(color: kPrimaryColor),
          centerTitle: true,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
