import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelectorService {
  final _imagePicker = ImagePicker();

  Future<File> pickImage(ImageSource source, int type,[bool isPostImage =false ]) async {
    PickedFile _file;
    if (type == 0)
      _file = await _imagePicker.getImage(source: source);
    else
      _file = await _imagePicker.getVideo(source: source);
    if (_file != null) {
      File file = File(_file.path);
      if(type==0 && isPostImage)
      file = await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 4, ratioY: 3),
        compressQuality: 50,
      );
      return file;
    }
    return null;
  }
}
