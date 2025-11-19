import 'package:actpod_web/components/center_dialog.dart';
import 'package:flutter/material.dart';

class DeleteCommentDialog {
  final String commentId;
  final BuildContext context;

  DeleteCommentDialog(this.commentId, this.context);

  Future<bool?> show() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return CenterDialog(
          title: "刪除留言",
          content: "您確定要刪除留言嗎？",
          leftButtonText: "取消",
          rightButtonText: "確定",
          leftButtonFunction: () {
            Navigator.of(context).pop(false);
          },
          rightButtonFunction: () {
            Navigator.of(context).pop(true);
          }
        );
      }
    );
  }
}