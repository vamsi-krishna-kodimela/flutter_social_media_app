import 'package:flutter/material.dart';
import 'package:social_media/screens/auth_screens/forgot_screen.dart';
import 'package:social_media/screens/main_screen.dart';
import 'package:social_media/services/firebase_auth_service.dart';
import './signup_screen.dart';

import './components/google_signin_button.dart';
import '../../components/custom_button.dart';
import '../../components/build_sized_box.dart';
import '../../constants.dart';
import './components/input_field_component.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  void signinUser() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseAuthService().loginWithEmail(
          emailController.value.text, passwordController.value.text);

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=>MainScreen()));
    } catch (err) {
      _scaffold.currentState.showSnackBar(SnackBar(content: Text(err.message)));
    } finally {
      setState(() {
        _isLoading = false;
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
              BuildSizedBox(15),
              Image.asset(
                "assets/logo.png",
                fit: BoxFit.fitHeight,
                width: _size.width * 0.5,
              ),
              BuildSizedBox(5),
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
              Container(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ForgotScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
              BuildSizedBox(2),
              CustomButton(
                color: kAccentColor,
                text: "Sign In",
                isEnabled: !_isLoading,
                isLoading: _isLoading,
                onPressed: signinUser,
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
                text: "Sign Up",
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => SignupScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
