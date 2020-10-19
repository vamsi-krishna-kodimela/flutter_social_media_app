import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/home_screen/home_screen.dart';
import 'package:social_media/services/firebase_auth_service.dart';

class GoogleSigninButton extends StatelessWidget {
  final ScaffoldState _scaffoldState;

  const GoogleSigninButton(this._scaffoldState);


  @override
  Widget build(BuildContext context) {
    Future<void> signinWithGoogle() async {
      try{
        await FirebaseAuthService().signInWithGoogle();
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>HomeScreen()));
      }catch(err){
      // _scaffoldState.showSnackBar(SnackBar(content: Text(err.message)));
        print(err.message);
      }
    }
    return Container(
      width: double.infinity,
      child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kDefaultPadding),
          ),
          padding: EdgeInsets.only(top: 3.0, bottom: 3.0, left: 3.0),
          color: kWhite,
          onPressed: signinWithGoogle,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding / 2, vertical: kDefaultPadding),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  "assets/google.svg",
                  height: kDefaultPadding * 3,
                ),
                Expanded(
                  child: Text(
                    "Sign in with Google",
                    style: TextStyle(
                      color: kTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
