

import 'dart:io';

import 'package:social_media/services/firebase_storage_service.dart';
import 'package:social_media/services/firestore_service.dart';

class PublishPostUtil {
  Future<void> publishPost(String description, File _image, File _video) async {
    if (description == null && _image == null && _video == null) {
      throw ("Post upload failed");
    }
    int type = 0;
    String _fileUrl;
    if (_image == null) {
      _image = _video;
      type = 1;
    }
    try {
      if (_image != null)
        _fileUrl = await FirebaseStorageService().storePostFile(_image);
      else type=0;
      await FirestoreService
          .addPostToFireStore(description, _fileUrl, type);
    } catch (err) {
      throw err;
    }
  }
}
