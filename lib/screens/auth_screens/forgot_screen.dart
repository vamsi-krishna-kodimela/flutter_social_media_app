import 'package:flutter/material.dart';
import 'package:social_media/services/firebase_auth_service.dart';
import '../../components/custom_button.dart';
import '../../components/build_sized_box.dart';
import '../../constants.dart';
import './components/input_field_component.dart';

class ForgotScreen extends StatefulWidget {
  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  final TextEditingController emailController = TextEditingController();

  bool _isLoading = false;

  void sendResetMail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuthService().sendResetPassword(emailController.value.text);
      _scaffold.currentState.showSnackBar(SnackBar(content: Text("Reset password link sent to your mail")));
    } catch (err) {
      _scaffold.currentState.showSnackBar(SnackBar(content: Text(err.message)));
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(color: kPrimaryColor),
      ),
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
              CustomButton(
                color: kAccentColor,
                text: "Reset Password",
                isEnabled: !_isLoading,
                onPressed: sendResetMail,
              ),
              BuildSizedBox(3),
            ],
          ),
        ),
      ),
    );
  }
}
