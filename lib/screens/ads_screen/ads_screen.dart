import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';

class AdsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Promotions",
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          FancyShimmerImage(
            width: double.infinity,
            imageUrl:
                "https://firebasestorage.googleapis.com/v0/b/frendzit-a0ec6.appspot.com/o/Frendzit%2FAVVASA%20_%20ADD.png?alt=media&token=954a7261-907c-460a-b0e8-5fd80f1a8b92",
            boxFit: BoxFit.fitWidth,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Make your business reach the World.",
                  style: TextStyle(
                    color: kAccentColor,
                    fontSize: 24.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
