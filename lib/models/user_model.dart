import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserModel {
  final String name;
  final String description;
  final String photoUrl;
  final Timestamp time = Timestamp.now();
  final List<String> keys;
  final String uid = FirebaseAuth.instance.currentUser.uid;
  final String messageToken;

  UserModel({
    @required this.name,
    @required this.description,
    @required this.photoUrl,
    @required this.keys,
    @required this.messageToken,
  });

  UserModel.fromData(Map<String, dynamic> data)
      : this.name = data["name"],
        this.description = data["description"],
        this.keys = data["keys"],
        this.photoUrl = data["photoUrl"],
        this.messageToken = data["messageToken"];

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "description": this.description,
      "photoUrl": this.photoUrl,
      "time": this.time,
      "keys": this.keys,
      "uid": this.uid,
      "messageToken": this.messageToken,
    };
  }
}
