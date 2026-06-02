import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> checkPermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    return status.isGranted;
  }

  static Future<bool> requestPermission() async {
    PermissionStatus status = await Permission.microphone.request();
    return status.isGranted;
  }
}