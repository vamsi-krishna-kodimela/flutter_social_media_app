import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AdsComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection("promotions")
          .where("status", isEqualTo: 1)
          .get(),
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          final _data = snapshot.data;
          if (_data.size == 0) return Container();
          final _ads = _data.docs;
          return CarouselSlider.builder(
            itemCount: _ads.length,
            options: CarouselOptions(
              autoPlay: (_ads.length != 1),
              enlargeCenterPage: true,
              viewportFraction: 1.0,
              aspectRatio: 3 / 1.5,
              initialPage: 0,
              autoPlayAnimationDuration: Duration(seconds: 1),
              autoPlayCurve: Curves.easeInOut,
              autoPlayInterval: Duration(seconds: 3),
            ),
            itemBuilder: (_, i) {
              final _ad = _ads[i].data();
              return GestureDetector(
                onTap: () async{
                  final url = _ad["url"];
                  if(url == null) return;
                  if (await canLaunch(url.trim())){
                    await launch(url);
                  }else{
                    print("Unable to launch");
                  }
                },
                child: FancyShimmerImage(
                  width: double.infinity,
                  height: double.infinity,
                  imageUrl: _ad["file"],
                  boxFit: BoxFit.cover,
                ),
              );
            },
          );
        }
        return AspectRatio(
          aspectRatio: 3 / 1.5,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.all(kDefaultPadding / 2),
            height: double.infinity,
            color: Colors.grey.withAlpha(50),
          ),
        );
      },
    );
  }
}
