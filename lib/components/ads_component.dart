import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AdsComponent extends StatelessWidget {
  Map<String, dynamic> _ads = {};

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: 4,
      options: CarouselOptions(
        autoPlay: false,
        enlargeCenterPage: true,
        viewportFraction: 1.0,
        aspectRatio: 3/1.25,
        initialPage: 0,
        autoPlayAnimationDuration: Duration(seconds: 5),


      ),
      itemBuilder: (_, ic){
        return Container(
          width: double.infinity,
          color: Colors.red,
          child: Text(ic.toString()),
        );
      },
    );
  }
}
