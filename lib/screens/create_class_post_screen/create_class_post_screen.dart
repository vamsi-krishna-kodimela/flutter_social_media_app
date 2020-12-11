import 'dart:io';


import 'package:flutter/material.dart';
import 'package:social_media/components/image_source_selector.dart';
import 'package:social_media/services/firebase_storage_service.dart';
import 'package:social_media/services/firestore_service.dart';
import 'package:string_validator/string_validator.dart';

import '../../constants.dart';

class CreateClassPostScreen extends StatefulWidget {
  final String classId;

  CreateClassPostScreen(this.classId);

  @override
  _CreateClassPostScreenState createState() => _CreateClassPostScreenState();
}

class _CreateClassPostScreenState extends State<CreateClassPostScreen> {
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  bool _isLoading = false;
  String link;
  File postImage;

  final _scaffoldState = GlobalKey<ScaffoldState>();

  void setPostImage(File img, int type) {
    setState(() {
      postImage = img;
    });
  }


  Future<void> createPost() async {
    final _description = _descriptionController.value.text.trim();
    String imgLink;
    String _link;
    try {
      setState(() {
        _isLoading = true;
      });
      if (postImage != null)
        imgLink = await FirebaseStorageService().storeClassPostFile(postImage);
      if (link != null) _link = link;
      if ((_description != null && _description.length > 0) ||
          _link != null ||
          imgLink != null) {
        await FirestoreService.addClassPostToFireStore(
            _description, imgLink, 0, link, widget.classId);
        Navigator.of(context).pop();
      } else {
    _scaffoldState.currentState
        .showSnackBar(SnackBar(content: Text("All Fields are empty.")));
    }

    }catch(err){
    _scaffoldState.currentState.showSnackBar(SnackBar(content: Text(err.message)));
    }finally{
    if(this.mounted)
    setState(() {
    _isLoading = false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(
          "Create Class Post",
          style: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: kDefaultPadding,
                horizontal: kDefaultPadding * 2,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(kDefaultPadding),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(kDefaultPadding),
                        border: Border.all(
                          color: kTextColor,
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(kDefaultPadding),
                          hintText: "Explanation/ Description...",
                          border: InputBorder.none,
                        ),
                        controller: _descriptionController,
                        maxLines: 5,
                      ),
                    ),
                    if (link != null)
                      Row(
                        children: [
                          Icon(
                            Icons.link_outlined,
                            color: kTextColor,
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Expanded(
                            child: Text(
                              link,
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.cancel_outlined,
                              color: kAccentColor,
                            ),
                            onPressed: () {
                              _linkController.clear();
                              setState(() {
                                link = null;
                              });
                            },
                          ),
                        ],
                      ),
                    Padding(
                      padding: EdgeInsets.all(kDefaultPadding),
                    ),
                    if (postImage != null)
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.4,
                        alignment: Alignment.centerRight,
                        child: Stack(
                          children: [
                            Image.file(postImage),
                            Positioned(
                              top: -10.0,
                              right: -10.0,
                              child: IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: kAccentColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    postImage = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (postImage == null || link == null)
            Container(
              color: kWhite,
              padding: EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
                vertical: kDefaultPadding / 2,
              ),
              child: Row(
                children: [
                  if (link == null)
                    FlatButton.icon(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(kDefaultPadding),
                                ),
                                title: Text(
                                  "Add Link to Post",
                                  style: TextStyle(
                                    color: kTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: TextField(
                                  controller: _linkController,
                                  decoration: InputDecoration(
                                    labelText: "Enter URL to post",
                                    suffix: IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        if (isURL(_linkController.value.text)) {
                                          setState(() {
                                            link = _linkController.value.text;
                                          });
                                        } else {
                                          _scaffoldState.currentState
                                              .showSnackBar(SnackBar(
                                            content: Text("Invalid Url"),
                                          ));
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              );
                            });
                      },
                      icon: Icon(
                        Icons.link,
                        color: kPrimaryColor,
                      ),
                      label: Text(
                        "Link",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      color: kPrimaryColor.withAlpha(30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  SizedBox(width: kDefaultPadding),
                  if (postImage == null)
                    FlatButton.icon(
                      onPressed: () {
                        DialogCameraPicker.buildShowDialog(
                          context: context,
                          type: 0,
                          isPost: true,
                          setImage: setPostImage,
                        );
                      },
                      icon: Icon(
                        Icons.image_outlined,
                        color: kAccentColor,
                      ),
                      label: Text(
                        "Image",
                        style: TextStyle(
                          color: kAccentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      color: kAccentColor.withAlpha(30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                ],
              ),
            ),
          (_isLoading)
              ? Center(
            child: CircularProgressIndicator(),
          )
              : InkWell(
            onTap: createPost,
            child: Container(
              width: double.infinity,
              color: kPrimaryColor,
              padding: EdgeInsets.symmetric(
                vertical: kDefaultPadding * 2,
              ),
              alignment: Alignment.center,
              child: Text(
                "Publish Post",
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
