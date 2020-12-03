import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:social_media/components/image_source_selector.dart';
import 'package:social_media/screens/main_screen.dart';
import 'package:social_media/services/firebase_auth_service.dart';

import './components/google_signin_button.dart';
import '../../components/custom_button.dart';
import '../../components/build_sized_box.dart';
import '../../constants.dart';
import './components/input_field_component.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  bool _isLoading = false;

  File _profilePic;

  void _setImage(File val,int type) {
    setState(() {
      _profilePic = val;
    });
  }

  Future<void> signupWithEmail() async {
    var name = nameController.value.text;
    var pass = passwordController.value.text;
    var email = emailController.value.text;
    if (name.length < 5) {
      _scaffold.currentState.showSnackBar(
        SnackBar(
          content: Text("Name must contains atleast 5 letters"),
        ),
      );
      return;
    }
    if (pass.length < 6) {
      _scaffold.currentState.showSnackBar(
        SnackBar(
          content: Text("Password must contains atleast 6 letters"),
        ),
      );
      return;
    }
    if (!EmailValidator.validate(email)) {
      _scaffold.currentState.showSnackBar(
        SnackBar(
          content: Text("Invalid Email address"),
        ),
      );
      return;
    }
    if (_profilePic == null) {
      _scaffold.currentState.showSnackBar(
        SnackBar(
          content: Text("Profile picture required."),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuthService()
          .signupWithEmail(name, email, pass, _profilePic);

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>MainScreen()));

    } catch (err) {
      _scaffold.currentState.showSnackBar(
        SnackBar(
          content: Text(err.message),
        ),
      );
    }finally{
      if(this.mounted)
        setState(() {
          _isLoading=false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffold,
      body: Container(
        width: _size.width,
        margin: EdgeInsets.symmetric(horizontal: kDefaultPadding * 3),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BuildSizedBox(10),
              Image.asset(
                "assets/logo.png",
                fit: BoxFit.fitHeight,
                width: _size.width * 0.5,
              ),
              BuildSizedBox(5),
              InputFieldComponent(
                controller: nameController,
                icon: Icons.person,
                hintText: "User Name",
              ),
              BuildSizedBox(2),
              InputFieldComponent(
                controller: emailController,
                icon: Icons.email,
                hintText: "Email Address",
              ),
              BuildSizedBox(2),
              InputFieldComponent(
                controller: passwordController,
                icon: Icons.vpn_key,
                hintText: "Password",
                isObscure: true,
              ),
              BuildSizedBox(2),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kDefaultPadding),
                ),
                elevation: 0.0,
                child: ListTile(
                  onTap: () async {
                    await DialogCameraPicker.buildShowDialog(
                      context: context,
                      setImage: _setImage,
                      type: 0,
                    );
                  },
                  title: Text("Upload Profile Pick"),
                  leading: (_profilePic == null)
                      ? Container(
                          height: 50,
                          width: 40,
                          color: kBGColor,
                          child: Center(child: FittedBox(child: Text("30X40"))),
                        )
                      : Image.file(
                          _profilePic,
                          height: 50,
                          width: 40,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                  trailing: Icon(Icons.photo),
                ),
              ),
              BuildSizedBox(2),
              CustomButton(
                color: kAccentColor,
                text: "Sign Up",
                isEnabled: !_isLoading,
                onPressed: signupWithEmail,
                isLoading: _isLoading,
              ),
              BuildSizedBox(3),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Text(" or "),
                  Expanded(child: Divider()),
                ],
              ),
              BuildSizedBox(3),
              GoogleSigninButton(_scaffold.currentState),
              BuildSizedBox(2),
              CustomButton(
                isEnabled: !_isLoading,
                color: kPrimaryColor,
                text: "Sign In",
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(),
                    ),
                  );
                },
              ),
              BuildSizedBox(10),
            ],
          ),
        ),
      ),
    );
  }
}
