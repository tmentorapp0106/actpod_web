import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_share_app/services/toast_service.dart';

class ImageUtils {
  static Future<File?> pickMedia(bool fromGallery, Future<File?> Function(File file)? cropImageFunc) async {
    final resource = fromGallery? ImageSource.gallery : ImageSource.camera;
    XFile? pickedFile;
    try {
      pickedFile = await ImagePicker().pickImage(source: resource, requestFullMetadata: true);
    } catch(e) {
      ToastService.showNoticeToast("請打開權限");
      return null;
    }

    if(pickedFile == null) {
      return null;
    }

    if(cropImageFunc == null) {
      return File(pickedFile.path);
    }

    final file = File(pickedFile.path);

    return cropImageFunc(file);
  }

  static Future<List<File>?> pickMultipleMedia({
    required bool fromGallery,
    Future<File?> Function(File file)? cropImageFunc,
    int? maxCount, // optional cap on how many to return
  }) async {
    final picker = ImagePicker();
    List<XFile> pickedFiles = [];

    try {
      if (fromGallery) {
        pickedFiles = await picker.pickMultiImage(
          requestFullMetadata: true,
          // You can also set `imageQuality` here if you want built-in compression.
        );
      } else {
        // Camera does not support multi-pick; capture one and wrap it.
        final single = await picker.pickImage(
          source: ImageSource.camera,
          requestFullMetadata: true,
        );
        if (single == null) return [];
        pickedFiles = [single];
      }
    } catch (e) {
      ToastService.showNoticeToast("請打開權限");
      return null;
    }

    if (pickedFiles.isEmpty) return null;

    if (maxCount != null && maxCount > 0 && pickedFiles.length > maxCount) {
      pickedFiles = pickedFiles.take(maxCount).toList();
    }

    List<File>? results = <File>[];
    for (final x in pickedFiles) {
      final original = File(x.path);
      if (cropImageFunc != null) {
        final cropped = await cropImageFunc(original);
        if (cropped != null) results.add(cropped);
      } else {
        results.add(original);
      }
    }
    return results;
  }

  static Future<File?> cropImageFunc(File imageFile, int height, int width) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: CropAspectRatio(ratioX: width.toDouble(), ratioY: height.toDouble()),
        compressQuality: 70,
        compressFormat: ImageCompressFormat.jpg,
        maxHeight: height,
        maxWidth: width,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "裁減圖片",
            hideBottomControls: true,
            lockAspectRatio: true)
        ]
    );

    return File(croppedFile!.path);
  }
}