import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart';
import '../../constants.dart';
import './components/class_text_field.dart';

class EditClassScreen extends StatefulWidget {
  final DocumentSnapshot classData;

  const EditClassScreen(this.classData);

  @override
  _EditClassScreenState createState() => _EditClassScreenState();
}

class _EditClassScreenState extends State<EditClassScreen> {
  final _classNameController = TextEditingController();

  final _descriptionController = TextEditingController();

  final _scaffoldState = GlobalKey<ScaffoldState>();

  final _firestore = FirebaseFirestore.instance;

  final _uid = FirebaseAuth.instance.currentUser.uid;
  Map<String, dynamic> _classInfo;
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
      await widget.classData.reference.update(
        {
          "name": className,
          "description": description,
        },
      );
      Navigator.of(context).pop();
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

  @override
  void initState() {
    super.initState();
    _classInfo = widget.classData.data();
    _classNameController.text = _classInfo["name"];
    _descriptionController.text = _classInfo["description"];
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
          "Edit Class Info",
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
                        child: Image.asset(
                          "assets/class.png",
                          fit: BoxFit.fitWidth,
                        ),
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
                      "Update Class info",
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
