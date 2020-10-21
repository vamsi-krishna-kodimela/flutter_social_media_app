import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class FirebaseStorageService{
  final _storage =
  FirebaseStorage(storageBucket: "gs://frendzit-a0ec6.appspot.com");
  StorageUploadTask _uploadTask;
  final _auth = FirebaseAuth.instance;

  Future<String> storeProfilePic(File image, String uid) async {
    final ext = p.extension(image.path);
      String filepath = "users/$uid/profile$ext";
      _uploadTask = _storage.ref().child(filepath).putFile(image);
      final StreamSubscription<StorageTaskEvent> streamSubscription =
      _uploadTask.events.listen((event) {});
      await _uploadTask.onComplete;
      final url = await _storage.ref().child(filepath).getDownloadURL();
      streamSubscription.cancel();
      if (_uploadTask.isSuccessful) return "$url";
      return null;
  }

  Future<String> storeGroupPic(File image,) async {
    final ext = p.extension(image.path);
    String filepath = "groups/${Timestamp.now().toString()}/profile$ext";
    _uploadTask = _storage.ref().child(filepath).putFile(image);
    final StreamSubscription<StorageTaskEvent> streamSubscription =
    _uploadTask.events.listen((event) {});

    await _uploadTask.onComplete;
    final url = await _storage.ref().child(filepath).getDownloadURL();
    streamSubscription.cancel();
    if (_uploadTask.isSuccessful) return "$url";
    return null;
  }

  Future<String> storePostFile(File image) async {
    final ext = p.extension(image.path);
    String uid = _auth.currentUser.uid;
    String filepath = "posts/$uid/${DateTime.now().toString()}$ext";
    _uploadTask = _storage.ref().child(filepath).putFile(image);

    final StreamSubscription<StorageTaskEvent> streamSubscription =
    _uploadTask.events.listen((event) {});

    await _uploadTask.onComplete;
    final url = await _storage.ref().child(filepath).getDownloadURL();
    streamSubscription.cancel();
    if (_uploadTask.isSuccessful) return "$url";
    return null;
  }




}