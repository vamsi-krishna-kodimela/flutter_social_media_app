import 'package:flutter/material.dart';

class GroupTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const GroupTextField({Key key, this.label, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
        labelText: label,
      ),
    );
  }
}