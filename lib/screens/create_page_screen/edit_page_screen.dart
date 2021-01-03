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

class EditPageScreen extends StatefulWidget {
  final DocumentSnapshot pageData;

  const EditPageScreen(this.pageData);

  @override
  _EditPageScreenState createState() => _EditPageScreenState();
}

class _EditPageScreenState extends State<EditPageScreen> {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  final String _uid = FirebaseAuth.instance.currentUser.uid;
  final _firestore = FirebaseFirestore.instance;
  File _profilePic;
  bool isLoading = false;
  Map<String, dynamic> _pageInfo;
  String _picUrl;

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
    _pageInfo = widget.pageData.data();
    _groupNameController.text = _pageInfo["name"];
    _groupDescriptionController.text = _pageInfo["description"];
    _picUrl = _pageInfo["pic"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          "Update Page info",
          style: TextStyle(fontWeight: FontWeight.w600, color: kTextColor),
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
                      createGroup: _createGroup,
                      isUpdate: true,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _createGroup() async {
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

    _groupName = _groupName.trim();
    if (_groupName.length > 20 || _groupName.length < 4) {
      final _snackbar = SnackBar(
        content: Text("Page Name must be between 4 to 20 characters."),
      );
      _scaffold.currentState.showSnackBar(_snackbar);
      return;
    }
    _groupDescription = _groupDescription.trim();
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
      if (_profilePic != null) _picUrl = await _store.storePagePic(_profilePic);
      final keys = keyWordGenerator(_groupName);
      await widget.pageData.reference.update({
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
