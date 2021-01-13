import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:social_media/components/empty_state_component.dart';
import 'package:social_media/screens/single_class_screen/single_class_screen.dart';
import 'package:social_media/utils.dart';
import '../../constants.dart';
import '../create_class_screen/create_class_screen.dart';

class ClassRoomScreen extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser.uid;
  final _scaffoldState = GlobalKey<ScaffoldState>();
  final _classCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(
          "Class rooms",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: kTextColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: kPrimaryColor,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: Text(
                        "Create or Join a Class",
                        style: TextStyle(
                          color: kAccentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: TextField(
                        controller: _classCode,
                        decoration: InputDecoration(
                          labelText: "Class Code",
                          contentPadding: EdgeInsets.only(bottom: 0.0),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              String classCode = _classCode.value.text.trim();
                              if (classCode.length == 8) {
                                try {
                                  final QuerySnapshot _snap = await _firestore
                                      .collection("class_rooms")
                                      .where("classId", isEqualTo: classCode)
                                      .limit(1)
                                      .get();
                                  if (_snap.size > 0) {
                                    for (DocumentSnapshot _doc in _snap.docs) {
                                      await _doc.reference.update({
                                        "students":
                                            FieldValue.arrayUnion([_uid])
                                      });
                                    }
                                  } else {
                                    _scaffoldState.currentState.showSnackBar(
                                        SnackBar(
                                            content:
                                                Text("No Class Room found.")));
                                  }
                                } catch (err) {
                                  _scaffoldState.currentState
                                      .showSnackBar(SnackBar(
                                    content:
                                        Text("Unable to enroll in class room."),
                                  ));
                                } finally {
                                  Navigator.of(ctx).pop();
                                }
                              } else {
                                _scaffoldState.currentState
                                    .showSnackBar(SnackBar(
                                  content:
                                      Text("Invalid or no Class code found."),
                                ));
                                Navigator.of(ctx).pop();
                              }
                            },
                            icon: Icon(Icons.add),
                            color: kAccentColor,
                          ),
                        ),
                      ),
                      actions: [
                        FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => CreateClassScreen()));
                          },
                          child: Text("Create Class"),
                          color: kPrimaryColor,
                        ),
                      ],
                    );
                  });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("class_rooms")
            .where("students", arrayContains: _uid)
            .snapshots(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );

          final classRoomsList = snapshot.data.docs;

          if (classRoomsList.length == 0)
            return Center(
              child: EmptyStateComponent("Create or Join a Class room."),
            );
          return Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: kDefaultPadding * 2,
                crossAxisSpacing: kDefaultPadding * 2,
                crossAxisCount: 2,
              ),
              itemBuilder: (__, i) {
                final _classRoom = classRoomsList[i].data();

                final _className = _classRoom["name"];
                final _classDescription = _classRoom["description"];
                final _tileColor = colorGenerator(_classRoom["color"]);
                print(_tileColor);

                return ClipRRect(
                  borderRadius: BorderRadius.circular(kDefaultPadding),
                  child: Container(
                    color: Colors.white,
                    child: GridTile(
                      header: GridTileBar(
                        backgroundColor: _tileColor,
                        title: Text(
                          _className == null ? "" : _className,
                          style: TextStyle(
                            color: kWhite,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: PopupMenuButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: kWhite,
                          ),
                          itemBuilder: (__) {
                            return [
                              if (_classRoom["createdBy"] == _uid)
                                PopupMenuItem(
                                  //Todo: Complete Popup Menu List
                                  child: GestureDetector(
                                    onTap: () async {
                                      try {
                                        await _firestore
                                            .collection("class_rooms")
                                            .doc(classRoomsList[i].id)
                                            .delete();
                                        _scaffoldState.currentState
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Class room deleted sucessfully."),
                                          ),
                                        );
                                      } catch (err) {
                                        _scaffoldState.currentState
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Class room deletion failed",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text("Delete"),
                                  ),
                                ),
                              if (_classRoom["createdBy"] != _uid)
                                PopupMenuItem(
                                  child: GestureDetector(
                                    onTap: () async {
                                      try {
                                        await _firestore
                                            .collection("class_rooms")
                                            .doc(classRoomsList[i].id)
                                            .update(
                                          {
                                            "students":
                                                FieldValue.arrayRemove([_uid]),
                                          },
                                        );
                                        _scaffoldState.currentState
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text("Unenroll sucessfully."),
                                          ),
                                        );
                                      } catch (err) {
                                        _scaffoldState.currentState
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "unenroll failed",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text("Unenroll"),
                                  ),
                                ),
                            ];
                          },
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            _classDescription == null ? "" : _classDescription,
                            style: TextStyle(
                              color: kTextColor,
                            ),
                          ),
                        ),
                      ),
                      footer: GridTileBar(
                        title: FlatButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    SingleClassScreen(classRoomsList[i]),
                              ),
                            );
                          },
                          child: Text(
                            "Explore",
                            style: TextStyle(
                              color: kWhite,
                            ),
                          ),
                          color: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(kDefaultPadding),
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            Share.share(
                              "You are invited to join the classroom using code : ${_classRoom["classId"]} on $kAppName.",
                              subject: "Invitation to join Friendzit classroom",
                            );
                          },
                          icon: Icon(Icons.share),
                          color: kAccentColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: classRoomsList.length,
            ),
          );
        },
      ),
    );
  }
}
