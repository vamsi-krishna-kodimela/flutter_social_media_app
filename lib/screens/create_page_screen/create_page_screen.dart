import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/services/firebase_storage_service.dart';
import 'package:social_media/utils.dart';

import 'components/create_group_button.dart';
import 'components/group_text_field.dart';
import 'components/image_picker.dart';

class CreatePageScreen extends StatefulWidget {
  @override
  _CreatePageScreenState createState() => _CreatePageScreenState();
}

class _CreatePageScreenState extends State<CreatePageScreen> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  final String _uid = FirebaseAuth.instance.currentUser.uid;
  final _firestore = FirebaseFirestore.instance;
  File _profilePic;
  bool isLoading = false;

  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _groupDescriptionController = TextEditingController();

  void _setImage(img, type) {
    setState(() {
      _profilePic = img;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          "Create Page",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
        child: Container(
          color: kWhite,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GroupTextField(
                          controller: _groupNameController,
                          label: "Page Name",
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        GroupTextField(
                          label: "Page Description",
                          controller: _groupDescriptionController,
                        ),
                        ImagePicker(
                          profilePic: _profilePic,
                          setImage: _setImage,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              (isLoading)
                  ? CircularProgressIndicator()
                  : CreateGroupButton(
                createGroup: createGroup,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createGroup() async {
    String _groupName = _groupNameController.value.text.trim();
    String _groupDescription = _groupDescriptionController.value.text.trim();
    if (_groupDescription.length == 0 ||
        _groupName.length == 0 ||
        _profilePic == null) {
      final _snackbar = SnackBar(
        content: Text("All fields are necessary."),
      );
      _scaffold.currentState.showSnackBar(_snackbar);
      return;
    }



    if (_groupName.length > 20 || _groupName.length < 4) {
      final _snackbar = SnackBar(
        content: Text("Page Name must be between 4 to 20 characters."),
      );
      _scaffold.currentState.showSnackBar(_snackbar);
      return;
    }

    if (_groupDescription.length > 100 || _groupDescription.length < 20) {
      final _snackbar = SnackBar(
        content: Text("Description must be between 20 to 100 characters."),
      );
      _scaffold.currentState.showSnackBar(_snackbar);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final _store = FirebaseStorageService();
      final _grpPic = await _store.storePagePic(_profilePic);
      final keys = SocialUtils.keyWordGenerator(_groupName);
      await _firestore.collection("pages").add({
        "name": _groupName,
        "description": _groupDescription,
        "pic": _grpPic,
        "createdOn": Timestamp.now(),
        "createdBy": _uid,
        "followers" : [],
        "posts": 0,
        "keys": keys,
      });

      Navigator.of(context).pop();
    } catch (err) {
      final _snackbar = SnackBar(
        content: Text("Something went wrong..."),
      );
      if (mounted) _scaffold.currentState.showSnackBar(_snackbar);
      return;
    } finally {
      if (mounted)
        setState(() {
          isLoading = false;
        });
    }
  }
}
