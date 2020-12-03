
import 'package:flutter/material.dart';

import '../../../constants.dart';

class InputFieldComponent extends StatelessWidget {


  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isObscure;

  const InputFieldComponent({@required this.controller, @required this.hintText, @required this.icon, this.isObscure=false});


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: kDefaultPadding / 2,
        horizontal: kDefaultPadding,
      ),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(kDefaultPadding),
        border: Border.all(color: kTextColor),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          prefixIcon: Icon(icon),
        ),
        obscureText: isObscure,
      ),
    );
  }
}
