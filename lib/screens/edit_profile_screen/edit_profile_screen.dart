import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/components/image_source_selector.dart';
import 'package:social_media/services/firebase_storage_service.dart';
import '../../constants.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen(this.userData);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final String _uid = FirebaseAuth.instance.currentUser.uid;
  final _fireStore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scaffoldState = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  Map<String, dynamic> _userInfo;
  File _profile;
  String _picUrl;

  _setImage(File img, int type) {
    setState(() {
      _profile = img;
    });
  }

  _updateUserProfile() async {
    setState(() {
      _isLoading=true;
    });
    try{
      if (_profile != null)
        _picUrl =
            await FirebaseStorageService().storeProfilePic(_profile, _uid);
      String _name = _nameController.value.text.trim();
      String _description = _descriptionController.value.text.trim();
      if (_name.length < 5) {
        _scaffoldState.currentState.showSnackBar(
            SnackBar(content: Text("Name must 5 or more characters.")));
        return;
      }
      await _fireStore.collection("users").doc(_uid).update({
        "name": _name,
        "description": _description,
        "photoUrl": _picUrl,
      });
      await FirebaseAuth.instance.currentUser.updateProfile(
        displayName: _name,
        photoURL: _picUrl
      );
      Navigator.of(context).pop();
    }catch(err){
      _scaffoldState.currentState.showSnackBar(SnackBar(content: Text(err.message==null?"Some thing went wrong.":err.message)));
      if(mounted)
      setState(() {
        _isLoading=false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _userInfo = widget.userData;
    _nameController.text = _userInfo["name"];
    _descriptionController.text =
        _userInfo["description"] == null ? "" : _userInfo["description"];
    _picUrl=_userInfo["photoUrl"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: kTextColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: "About",
                      prefixIcon: Icon(
                        Icons.dehaze,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                  Card(
                    color: kWhite,
                    child: ListTile(
                      onTap: () {
                        DialogCameraPicker.buildShowDialog(
                            context: context, setImage: _setImage, type: 0);
                      },
                      leading: AspectRatio(
                        aspectRatio: 1 / 1,
                        child: (_profile != null)
                            ? Image.file(
                                _profile,
                                fit: BoxFit.cover,
                              )
                            : FancyShimmerImage(
                                imageUrl: _userInfo["photoUrl"],
                                boxFit: BoxFit.cover,
                              ),
                      ),
                      title: Text("Change Profile Pic..."),
                    ),
                  ),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                ],
              ),
            ),
          ),
          (_isLoading)?Center(child: CircularProgressIndicator(),):GestureDetector(
            onTap: _updateUserProfile,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: kDefaultPadding * 2),
              color: kPrimaryColor,
              alignment: Alignment.center,
              child: Text(
                "Update Profile",
                style: TextStyle(
                  color: kWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
