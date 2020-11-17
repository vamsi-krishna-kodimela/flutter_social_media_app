import 'dart:io';

import 'package:flutter/material.dart';
import 'package:social_media/components/image_source_selector.dart';

import '../../../constants.dart';

class ImagePicker extends StatelessWidget {
  final Function setImage;
  final File profilePic;

  const ImagePicker({Key key, this.setImage, this.profilePic})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kBGColor,
      margin: EdgeInsets.symmetric(
        vertical: 30.0,
        horizontal: 0.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultPadding),
      ),
      elevation: 0.0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 8.0,
        ),
        onTap: () async {
          await DialogCameraPicker.buildShowDialog(
            context: context,
            setImage: setImage,
            type: 0,
          );
        },
        title: Text("Upload Page Display Pic"),
        leading: (profilePic == null)
            ? Container(
          height: 40,
          width: 40,
          color: kBGColor,
          child: Center(child: FittedBox(child: Text("40X40"))),
        )
            : Image.file(
          profilePic,
          height: 40,
          width: 40,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        trailing: Icon(Icons.photo),
      ),
    );
  }
}