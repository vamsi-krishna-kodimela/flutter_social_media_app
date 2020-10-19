import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/constants.dart';
import 'package:path/path.dart' as p;

class EntertainmentUploadScreen extends StatefulWidget {
  @override
  _EntertainmentUploadScreenState createState() =>
      _EntertainmentUploadScreenState();
}

class _EntertainmentUploadScreenState extends State<EntertainmentUploadScreen> {
  bool isUploading = false;
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        title: Text("Uploader"),
        elevation: 0.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          color: kWhite,
        ),
        width: double.infinity,
        child: Column(
          children: [
            Image.asset("assets/entertainment_upload.png"),
            Expanded(
              child: Center(
                child: (isUploading)
                    ? CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            child: Container(
                              padding: EdgeInsets.all(kDefaultPadding * 3),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withAlpha(50),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Icon(
                                Icons.video_call,
                                color: kPrimaryColor,
                              ),
                            ),
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.getVideo(
                                source: ImageSource.gallery,
                              );

                              if (pickedFile != null) {
                                final file = File(pickedFile.path);
                                final ext = p.extension(file.path);
                                setState(() {
                                  isUploading = true;
                                });
                                try {
                                  final _storage = FirebaseStorage(
                                      storageBucket:
                                          "gs://frendzit-a0ec6.appspot.com");
                                  final _filepath =
                                      "entertainment/${DateTime.now().toString()}$ext";
                                  StorageUploadTask _task = _storage
                                      .ref()
                                      .child(_filepath)
                                      .putFile(file);

                                  StorageTaskSnapshot _storageSnapshot =
                                      await _task.onComplete;
                                  if (_storageSnapshot.error != null) {
                                    _scaffold.currentState.showSnackBar(
                                      SnackBar(
                                        content: Text("File upload failed..."),
                                      ),
                                    );
                                    return;
                                  }
                                  final String url = await _storage
                                      .ref()
                                      .child(_filepath)
                                      .getDownloadURL();
                                  final _firestore = FirebaseFirestore.instance;
                                  await _firestore
                                      .collection("entertainment")
                                      .add({
                                    "resource": url,
                                    "postedBy":
                                        FirebaseAuth.instance.currentUser.uid,
                                    "postedOn": Timestamp.now(),
                                    "type": 0,
                                  });
                                  Navigator.of(context).pop();
                                } catch (err) {
                                  print(err.message);
                                } finally {
                                  if (mounted)
                                    setState(() {
                                      isUploading = false;
                                    });
                                }
                              }
                            },
                          ),
                          GestureDetector(
                            onTap: () async {},
                            child: Container(
                              padding: EdgeInsets.all(kDefaultPadding * 3),
                              decoration: BoxDecoration(
                                color: kAccentColor.withAlpha(50),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Icon(
                                Icons.audiotrack_rounded,
                                color: kAccentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Center(
              child: Text("Share your videos & audios to world..."),
            ),
            SizedBox(
              height: kDefaultPadding,
            ),
            // Container(
            //   width: double.infinity,
            //   color: kAccentColor,
            //   child: FlatButton(
            //     padding: EdgeInsets.all(20.0),
            //     onPressed: () {},
            //     child: Text(
            //       "Publish",
            //       style: TextStyle(
            //         color: kWhite,
            //         fontWeight: FontWeight.w600,
            //       ),
            //     ),
            //     color: kAccentColor,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
