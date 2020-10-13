import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/services/image_selector_service.dart';

import '../constants.dart';

class DialogCameraPicker {
  static Future<void> buildShowDialog({
    BuildContext context,
    Function setImage,
    int type,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Center(child: Text("Select Source")),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kDefaultPadding),
          ),
          backgroundColor: kWhite,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: () async {
                    final file = await ImageSelectorService()
                        .pickImage(ImageSource.camera, type);
                    setImage(file,type);
                    Navigator.of(ctx).pop();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: () async {
                    final file = await ImageSelectorService()
                        .pickImage(ImageSource.gallery, type);
                    setImage(file,type);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ],
        );
      },
    );
  }
}
