
import 'package:flutter/material.dart';

import '../constants.dart';

class BuildSizedBox extends StatelessWidget {
  final int size;

  const BuildSizedBox(this.size);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kDefaultPadding * size,
    );
  }
}
