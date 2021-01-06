import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';
import 'package:social_media/screens/single_page_screen/single_page_screen.dart';

class CreatedPagesComponent extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("pages")
          .where("createdBy", isEqualTo: _uid).orderBy("createdOn",descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData) return Center(child: Text("No Pages Created."));
        List<DocumentSnapshot> _data = snapshot.data.docs;
        if (_data.length == 0) return Center(child: Text("No Pages Created."));
        return ListView.builder(
            padding: EdgeInsets.all(kDefaultPadding),
            itemCount: _data.length,
            itemBuilder: (ctx, i) {
              return Dismissible(
                key: Key(_data[i].id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (dir) async {
                  bool dismiss = false;
                  await showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text(
                            "Are you sure to delete",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16.0),
                          ),
                          content: Container(
                            child: Text(
                              _data[i].data()["name"],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kPrimaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(kDefaultPadding),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(kDefaultPadding),
                          ),
                          actions: [
                            FlatButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                dismiss = true;
                                _firestore
                                    .collection("pages")
                                    .doc(_data[i].id)
                                    .delete();
                              },
                              child: Text(
                                "Yes",
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w600),
                              ),
                              color: kPrimaryColor.withAlpha(50),
                            ),
                            FlatButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                dismiss = false;
                              },
                              child: Text(
                                "No",
                                style: TextStyle(
                                    color: kWhite, fontWeight: FontWeight.w600),
                              ),
                              color: kAccentColor,
                            ),
                          ],
                        );
                      });

                  return dismiss;
                },
                child: Card(
                  child: ListTile(
                    onTap: (){

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SinglePageScreen(
                            pageId: _data[i].id
                          ),
                        ),
                      );
                    },
                    title: Text(
                      _data[i].data()["name"],
                      style: TextStyle(
                          color: kTextColor, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "${_data[i].data()["description"]}",
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(kDefaultPadding),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: FancyShimmerImage(
                          imageUrl: _data[i].data()["pic"],
                          boxFit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                background: Container(
                  child: Icon(
                    Icons.delete,
                    color: kAccentColor,
                  ),
                  color: kAccentColor.withAlpha(50),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: kDefaultPadding*2),
                ),
              );
            });
      },
    );
  }
}
