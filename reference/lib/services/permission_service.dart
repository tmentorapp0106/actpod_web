import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quick_share_app/services/toast_service.dart';

class PermissionService {

  static Future<bool> askPhotoPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        if(!await Permission.storage.isGranted) {
          PermissionStatus status = await Permission.storage.request();
          return status.isGranted;
        }
        return true;
      }  else {
        if(!await Permission.photos.isGranted) {
          PermissionStatus status = await Permission.photos.request();
          return status.isGranted;
        }
        return true;
      }
    }

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