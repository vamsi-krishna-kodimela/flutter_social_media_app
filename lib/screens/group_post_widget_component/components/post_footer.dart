
import 'package:flutter/material.dart';
import 'package:social_media/screens/comments_screen/comments_screen.dart';
import 'package:social_media/screens/likes_screen/likes_screen.dart';

import '../../../constants.dart';
import '../group_post_widget_component.dart';

class PostFooter extends StatelessWidget {
  const PostFooter({
    Key key,
    @required this.isLiked,
    @required this.likesCount,
    @required this.widget,
    @required this.toogleLikes,
    this.likedList,
  }) : super(key: key);

  final bool isLiked;
  final int likesCount;
  final GroupPostWidgetComponent widget;
  final Function toogleLikes;
  final Map<String, dynamic> likedList;

  @override
  Widget build(BuildContext context) {
    List<String> likesList = [];
    if (likedList != null) {
      for (String key in likedList.keys) {
        if (likedList[key] == true) likesList.add(key);
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            FlatButton.icon(
              onPressed: toogleLikes,
              icon: Icon(
                (isLiked) ? Icons.favorite : Icons.favorite_border,
                color: kAccentColor,
              ),
              label: GestureDetector(
                  onTap: () {
                    if (likesCount > 0)
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LikesScreen(
                            likedBy: likesList,
                          ),
                        ),
                      );
                  },
                  child: Text("$likesCount likes")),
            ),
            IconButton(
              icon: Icon(
                Icons.comment_outlined,
                color: kPrimaryColor,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CommentsScreen(
                      postId: widget.post.id,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.share,
            color: kTextColor,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}