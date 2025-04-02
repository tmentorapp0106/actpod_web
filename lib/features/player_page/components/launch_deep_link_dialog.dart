import 'package:flutter/material.dart';

class LaunchDeepLinkDialog extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('開啟 ActPod'),
      content: const Text('要使用 ActPod 收聽嗎？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('確認'),
        ),
      ],
    );
  }
}