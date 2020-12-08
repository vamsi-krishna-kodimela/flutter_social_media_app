import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';
import '../../constants.dart';
import './components/class_text_field.dart';

class CreateClassScreen extends StatefulWidget {
  @override
  _CreateClassScreenState createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _classNameController = TextEditingController();

  final _descriptionController = TextEditingController();

  final _scaffoldState = GlobalKey<ScaffoldState>();

  final _firestore = FirebaseFirestore.instance;

  final _uid = FirebaseAuth.instance.currentUser.uid;

  bool _isLoading = false;

  Future<void> _createClass() async {
    final String className = _classNameController.value.text.trim();
    final String description = _descriptionController.value.text.trim();

    if (className.length < 5 || className.length > 15) {
      _alertDisplayer("Class Name must be between 5 to 15 characters.");
      return;
    }

    if (description.length < 5 || description.length > 100) {
      _alertDisplayer("Description must be between 5 to 100 characters.");
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await _firestore.collection("class_rooms").add(
        {
          "name": className,
          "description": description,
          "createdBy": _uid,
          "ref": _firestore.collection("users").doc(_uid),
          "createdOn": Timestamp.now(),
          "classId": nanoid(8),
        },
      );
      Navigator.of(context).pop();
    } catch (err) {
      print(err);
      _alertDisplayer(err.message);
      return;
    } finally {
      if (this.mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  void _alertDisplayer(String info) {
    _scaffoldState.currentState.showSnackBar(
      SnackBar(
        content: Text(info),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(
          "Create Class Room",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: kTextColor,
          ),
        ),
      ),
      body: Container(
        color: kWhite,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kDefaultPadding * 2),
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.all(24.0)),
                    ClassTextField(
                      controller: _classNameController,
                      label: "Class Name",
                    ),
                    SizedBox(
                      height: kDefaultPadding,
                    ),
                    ClassTextField(
                      controller: _descriptionController,
                      label: "Description",
                    ),
                    Expanded(
                      child: Center(
                        child: Image.asset("assets/class.png",fit: BoxFit.fitWidth,),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            (_isLoading)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : FlatButton(
                    minWidth: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: kDefaultPadding * 1.5,
                    ),
                    child: Text(
                      "Create Class Room",
                      style: TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    color: kPrimaryColor,
                    onPressed: () async {
                      await _createClass();
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
