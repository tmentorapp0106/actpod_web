import 'package:flutter/material.dart';

class UnlockDialog extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('付費單集解鎖'),
      content: const Text('請開啟 ActPod 購買付費單單集\n若已購買，請點擊右上方登入會員。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('開啟 ActPod'),
        ),
      ],
    );
  }
}