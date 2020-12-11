import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/models/user_model.dart';

class FirestoreService {
  static final CollectionReference _usersCollectionReference =
      FirebaseFirestore.instance.collection('users');
  static final CollectionReference _postsCollectionReference =
      FirebaseFirestore.instance.collection('posts');

  static Future createUser(String uid, UserModel user) async {
    await _usersCollectionReference.doc(uid).set(user.toJson());
  }

  static Future<UserModel> getUser(String uid) async {
    try {
      var userData = await _usersCollectionReference.doc(uid).get();
      return UserModel.fromData(userData.data());
    } catch (e) {
      return null;
    }
  }

  static Future<void> addPostToFireStore(
    String description,
    String resource,
    int type,
  ) async {
    String uid = FirebaseAuth.instance.currentUser.uid;

    await _postsCollectionReference.add({
      "description": description,
      "resources": resource,
      "type": type,
      "postedBy": uid,
      "postedOn": Timestamp.now(),
      "userData": FirebaseFirestore.instance.collection('users').doc(uid),
    });
  }


  static Future<void> addClassPostToFireStore(
      String description,
      String resource,
      int type,
      String link,
      String cId,
      ) async {
    String uid = FirebaseAuth.instance.currentUser.uid;

    await FirebaseFirestore.instance.collection('class_posts').add({
      "description": description,
      "resources": resource,
      "type": type,
      "postedBy": uid,
      "postedOn": Timestamp.now(),
      "userData": FirebaseFirestore.instance.collection('users').doc(uid),
      "link" : link,
      "class": cId,
    });
  }

  static Future<void> addGroupPostToFireStore(
      String gid,
      String description,
      String resource,
      int type,
      ) async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    final CollectionReference _postsCollectionReference =
    FirebaseFirestore.instance.collection('group_posts');

    await _postsCollectionReference.add({
      "group" : gid,
      "description": description,
      "resources": resource,
      "type": type,
      "postedBy": uid,
      "postedOn": Timestamp.now(),
      "userData": FirebaseFirestore.instance.collection('users').doc(uid),
    });
  }

  static Future<void> addPagePostToFireStore(
      String gid,
      String description,
      String resource,
      int type,
      ) async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    final CollectionReference _postsCollectionReference =
    FirebaseFirestore.instance.collection('page_posts');

    await _postsCollectionReference.add({
      "page" : gid,
      "description": description,
      "resources": resource,
      "type": type,
      "postedBy": uid,
      "postedOn": Timestamp.now(),
      "userData": FirebaseFirestore.instance.collection('users').doc(uid),
    });
  }

  static Future<void> sendFriendRequest(String friendID) async {
    final uid = FirebaseAuth.instance.currentUser.uid;
    await _usersCollectionReference.doc(uid).update({"friends.$friendID": 0});
    await _usersCollectionReference.doc(friendID).update({"friends.$uid": 1});
  }

  static Future<void> acceptFriendRequest(String friendID) async {
    final uid = FirebaseAuth.instance.currentUser.uid;
    await _usersCollectionReference.doc(uid).update({"friends.$friendID": 3});
    await _usersCollectionReference.doc(friendID).update({"friends.$uid": 3});
  }

  static Future<void> rejectFriendRequest(String friendID) async {
    final uid = FirebaseAuth.instance.currentUser.uid;
    await _usersCollectionReference.doc(uid).update({"friends.$friendID": 2});
    await _usersCollectionReference.doc(friendID).update({"friends.$uid": 2});
  }
}
