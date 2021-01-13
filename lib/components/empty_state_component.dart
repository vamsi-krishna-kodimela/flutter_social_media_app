import 'package:flutter/material.dart';
import 'package:social_media/constants.dart';

class EmptyStateComponent extends StatelessWidget {
  final String note;

  const EmptyStateComponent(this.note);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/empty_state.png",
            width: MediaQuery.of(context).size.width * 0.7,
          ),
          SizedBox(
            height: kDefaultPadding,
          ),
          Text(note.trim()),
        ],
      ),
    );
  }
}
