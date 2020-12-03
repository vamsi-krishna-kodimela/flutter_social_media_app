import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../components/image_source_selector.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../constants.dart';
import './utils/publish_post_util.dart';

class CreatePagePostScreen extends StatefulWidget {
  final String pid;

  const CreatePagePostScreen(this.pid);
  @override
  _CreatePagePostScreenState createState() => _CreatePagePostScreenState();
}

class _CreatePagePostScreenState extends State<CreatePagePostScreen> {
  File _image;
  File _video;
  bool isLoading = false;
  GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  final TextEditingController _description = TextEditingController();

  Future<void> publishPost() async {
    var description = _description.value.text;

    if (description.length < 5 || description.length > 500) {
      _scaffold.currentState.showSnackBar(
        SnackBar(
          content: Text("Post description must be between 5 to 500 letters."),
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      await PublishPostUtil().publishPost(widget.pid,description, _image, _video);
    } catch (err) {
      _scaffold.currentState.showSnackBar(
        SnackBar(
          content: Text(err.message),
        ),
      );
    } finally {
      if (this.mounted)
        setState(() {
          isLoading = false;
        });
      Navigator.of(context).pop();
    }
  }

  void setImage(File img, int type) {
    if (type == 0) {
      setState(() {
        _image = img;
      });
    } else {
      setState(() {
        _video = img;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text(
          "Create Post for Page",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: kTextColor
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: kDefaultPadding * 2,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: kDefaultPadding * 2,
                          vertical: kDefaultPadding * 2),
                      padding: EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                      ),
                      height: _size.height * 0.2,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kTextColor,
                        ),
                        borderRadius: BorderRadius.circular(kDefaultPadding),
                        color: kWhite,
                      ),
                      child: TextField(
                        controller: _description,
                        decoration: InputDecoration(
                          hintText: "What's on Your Mind...",
                          hintStyle: TextStyle(
                            color: kTextColor.withAlpha(60),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                    ),
                    if (_video != null)
                      FutureBuilder<Uint8List>(
                        future: VideoThumbnail.thumbnailData(
                            video: _video.path, imageFormat: ImageFormat.PNG),
                        builder: (ctx, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting)
                            return Center(
                              child: CircularProgressIndicator(),
                            );

                          return Center(
                            child: Container(
                              height: _size.width * 0.3,
                              width: _size.width * 0.3,
                              child: GridTile(
                                header: Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _video = null;
                                      });
                                    },
                                    child: Icon(
                                      Icons.cancel,
                                      color: kAccentColor,
                                    ),
                                  ),
                                ),
                                child: Image.memory(
                                  snapshot.data,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    if (_image != null)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(kDefaultPadding),
                        ),
                        clipBehavior: Clip.hardEdge,
                        width: 100,
                        height: 100,
                        child: GridTile(
                          header: Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                              child: Icon(
                                Icons.cancel,
                                color: kAccentColor,
                              ),
                            ),
                          ),
                          child: Image.file(
                            _image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            (_video == null && _image == null)
                ? Container(
              width: _size.width,
              padding: EdgeInsets.symmetric(
                horizontal: kDefaultPadding * 2,
                vertical: kDefaultPadding,
              ),
              color: kWhite,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FlatButton.icon(
                      onPressed: () async {
                        await DialogCameraPicker.buildShowDialog(
                            type: 0,
                            setImage: setImage,
                            context: context,
                            isPost: true);
                      },
                      icon: Icon(
                        Icons.image,
                        color: kAccentColor,
                      ),
                      label: Text(
                        "Photo",
                        style: TextStyle(
                          color: kTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      padding: EdgeInsets.all(kDefaultPadding),
                    ),
                    FlatButton.icon(
                      onPressed: () async {
                        await DialogCameraPicker.buildShowDialog(
                            context: context,
                            setImage: setImage,
                            type: 1);
                      },
                      icon: Icon(
                        Icons.videocam,
                        color: kAccentColor,
                      ),
                      label: Text(
                        "Video",
                        style: TextStyle(
                          color: kTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      padding: EdgeInsets.all(kDefaultPadding),
                    ),
                  ],
                ),
              ),
            )
                : SizedBox(
              height: kDefaultPadding,
            ),
            (isLoading)
                ? CircularProgressIndicator()
                : GestureDetector(
              onTap: publishPost,
              child: Container(
                width: double.infinity,
                color: kPrimaryColor,
                padding:
                EdgeInsets.symmetric(vertical: kDefaultPadding * 1.5),
                child: Center(
                  child: Text(
                    "Publish Post",
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
