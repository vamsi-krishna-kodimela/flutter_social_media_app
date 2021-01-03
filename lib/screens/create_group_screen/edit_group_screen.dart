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

class EditGroupScreen extends StatefulWidget {
  final Map<String, dynamic> groupData;
  final String gid;

  const EditGroupScreen({this.groupData, this.gid});
  @override
  _EditGroupScreenState createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  final String _uid = FirebaseAuth.instance.currentUser.uid;
  final _firestore = FirebaseFirestore.instance;
  File _profilePic;
  String _picUrl;
  bool isLoading = false;

  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _groupDescriptionController = TextEditingController();

  void _setImage(img, type) {
    setState(() {
      _profilePic = img;
    });
  }

  @override
  void initState() {
    super.initState();
    _groupNameController.text = widget.groupData["name"];
    _groupDescriptionController.text = widget.groupData["description"];
    _picUrl = widget.groupData["pic"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          "Edit Group info",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: kTextColor
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
                          label: "Group Name",
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        GroupTextField(
                          label: "Group Description",
                          controller: _groupDescriptionController,
                        ),
                        ImagePicker(
                          profilePic: _profilePic,
                          setImage: _setImage,
                          picUrl: _picUrl,

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
                isUpdate: true,
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
        _groupName.length == 0) {
      final _snackbar = SnackBar(
        content: Text("All fields are necessary."),
      );
      _scaffold.currentState.showSnackBar(_snackbar);
      return;
    }



    if (_groupName.length > 20 || _groupName.length < 4) {
      final _snackbar = SnackBar(
        content: Text("Group Name must be between 4 to 20 characters."),
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
      final userRef = _firestore.collection("users").doc(_uid);
      final _store = FirebaseStorageService();
      if(_profilePic !=null)
      _picUrl = await _store.storeGroupPic(_profilePic);
      final keys = keyWordGenerator(_groupName);
      await _firestore.collection("groups").doc(widget.gid).update({
        "name": _groupName,
        "description": _groupDescription,
        "pic": _picUrl,
        "keys":keys,
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
