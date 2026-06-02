import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class LinkFormItem {
  final TextEditingController urlController = TextEditingController();
  XFile? pickedImage;
  String? imageUrl;

  void dispose() {
    urlController.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      "imageUrl": imageUrl ?? "",
      "url": urlController.text.trim(),
    };
  }
}