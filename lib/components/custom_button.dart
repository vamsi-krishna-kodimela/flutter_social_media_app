import 'package:flutter/material.dart';

import '../constants.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final String text;
  final bool isEnabled;
  final Function onPressed;
  final bool isLoading;

  const CustomButton(
      {this.color,
      this.text,
      this.isEnabled,
      this.onPressed,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return (!isLoading)
        ? Container(
            width: double.infinity,
            child: RaisedButton(
              padding: EdgeInsets.symmetric(vertical: kDefaultPadding * 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kDefaultPadding),
              ),
              color: color,
              onPressed: (isEnabled) ? onPressed : null,
              child: Text(
                text,
                style: TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
