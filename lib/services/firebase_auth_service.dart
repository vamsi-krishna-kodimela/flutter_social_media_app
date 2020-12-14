import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_media/models/user_model.dart';
import 'package:social_media/services/firebase_storage_service.dart';
import 'package:social_media/services/firestore_service.dart';
import 'package:social_media/utils.dart';

class FirebaseAuthService {
  final _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _firebaseMessaging = FirebaseMessaging();

  Future<String> signInWithGoogle() async {
    final googleSignInAccount = await _googleSignIn.signIn();
    final googleSignInAuthentication = await googleSignInAccount.authentication;
    final authCredentials = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );
    final authResult =
        await _firebaseAuth.signInWithCredential(authCredentials);
    final user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _firebaseAuth.currentUser;

      assert(user.uid == currentUser.uid);
      var notificationToken = await _firebaseMessaging.getToken();
      if (authResult.additionalUserInfo.isNewUser) {
        await currentUser.updateProfile(
            displayName: user.displayName, photoURL: user.photoURL);
        var keys = SocialUtils.keyWordGenerator(user.displayName);
        await _firebaseMessaging.requestNotificationPermissions();

        await FirestoreService.createUser(
          currentUser.uid,
          UserModel(
            name: user.displayName,
            description: "",
            photoUrl: user.photoURL,
            keys: keys,
            messageToken: [notificationToken],
          ),
        );
      }else{

        await FirebaseFirestore.instance.collection("users").doc(authResult.user.uid).update({
        "messageToken":FieldValue.arrayUnion([notificationToken]),
        });
      }
      return '$user';
    }
    return null;
  }

  Future<bool> loginWithEmail(String email, String password) async {
    var authResult = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    var notificationToken = await _firebaseMessaging.getToken();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(authResult.user.uid)
        .update({
      "messageToken": FieldValue.arrayUnion([notificationToken]),
    });
    return authResult.user != null;
  }

  Future<bool> signupWithEmail(
    String name,
    String email,
    String password,
    File pic,
  ) async {
    final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    final photoUrl = await FirebaseStorageService()
        .storeProfilePic(pic, credentials.user.uid);
    await credentials.user.updateProfile(
      photoURL: photoUrl,
      displayName: name,
    );
    await _firebaseMessaging.requestNotificationPermissions();
    var notificationToken = await _firebaseMessaging.getToken();
    var user = UserModel(
      name: name,
      description: "",
      photoUrl: photoUrl,
      keys: SocialUtils.keyWordGenerator(name),
      messageToken: [notificationToken],
    );
    await FirestoreService.createUser(
      credentials.user.uid,
      user,
    );
    return credentials.user != null;
  }

  Future<void> sendResetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> userSignout() async {
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }

    if (_firebaseAuth.currentUser != null) {
      await _firebaseAuth.signOut();
    }
  }
}
