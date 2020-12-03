import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:fdottedline/fdottedline.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';

class GroupPicComponent extends StatelessWidget {
  const GroupPicComponent({
    Key key,
    @required this.picUrl,
  }) :super(key: key);

  final String picUrl;


  @override
  Widget build(BuildContext context) {
    final Size _size=MediaQuery.of(context).size;
    return FDottedLine(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: FancyShimmerImage(
            imageUrl: picUrl,
            boxFit: BoxFit.cover,
            height: _size.width * 0.17,
            width: _size.width * 0.17,
          ),
        ),
      ),
      color: kPrimaryColor,
      strokeWidth: 2.0,
      dottedLength: 10.0,
      space: 5.0,
      corner: FDottedLineCorner.all(25.0),
    );
  }
}
