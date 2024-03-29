import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/single_group_screen/single_group_screen.dart';

import '../../../constants.dart';

class GroupTileComponent extends StatelessWidget {
  const GroupTileComponent({
    Key key,
    @required this.gid,
    @required this.data,
  }) : super(key: key);

  final String gid;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: kDefaultPadding / 2),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SingleGroupScreen(gid),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            children: [
              FancyShimmerImage(
                imageUrl: data["pic"],
                width: 80.0,
                boxFit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  color: Colors.black87,
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    "${data["name"]}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
