import 'package:flutter/material.dart';

class ClassTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const ClassTextField({this.label, this.controller});

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