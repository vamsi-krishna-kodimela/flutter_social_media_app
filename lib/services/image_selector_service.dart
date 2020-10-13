import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImageSelectorService{
  final _imagePicker = ImagePicker();
  Future<File> pickImage(ImageSource source,int type) async {
    PickedFile _file;
    if(type == 0)
    _file = await _imagePicker.getImage(source: source);
    else
      _file = await _imagePicker.getVideo(source: source);
    if(_file != null)
    return File(_file.path);
  }
}