import 'package:flutter/material.dart';
import '../../constants.dart';
import '../create_class_screen/create_class_screen.dart';

class ClassRoomScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      title: Text("Join or Create Class", style: TextStyle(color: kAccentColor, fontWeight: FontWeight.w600),),
                      content: Text("Input Field"),
                      actions: [
                        FlatButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).push(MaterialPageRoute(builder: (_)=>CreateClassScreen()),);
                          },
                          child: Text("Create Group"),
                          color: kPrimaryColor,
                        ),
                      ],
                    );
                  });
            },
          ),
        ],
      ),
      body: Center(
        child: Text("Joined Class rooms."),
      ),
    );
  }
}
