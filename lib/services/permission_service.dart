import 'dart:io';
import 'package:actpod_web/services/toast_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {

  static Future<bool> askPhotoPermission() async {
    if(!await Permission.photos.isGranted) {
      PermissionStatus status = await Permission.photos.request();
      if(!status.isGranted) {
        ToastService.showNoticeToast("Please grant photo permission");
      }
      return status.isGranted;
    }
    return true;
  }

  static Future<bool> askRecorderPermission() async {
    if(!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if(!status.isGranted) {
        ToastService.showNoticeToast("Please grant microphone permission");
      }

      return status.isGranted;
    }
    return true;
  }

  static Future<bool> checkMicPermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    return status.isGranted;
  }
}