import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_app_version_res.dart';
import 'package:quick_share_app/apiManagers/app_config_system_api_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

import '../features/upgrade_dialog.dart';

bool needUpgrade = false;

class UpgradeService {
  static Future<void> checkWithDialog(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    GetAppVersionRes response = await appConfigApiManager.getAppVersion();
    if(response.version == null) {
      return;
    }

    Version appVersion = Version.parse(packageInfo.version);
    Version latestCompatibleVersion = Platform.isAndroid? Version.parse(response.version!.androidAppVersion) : Version.parse(response.version!.iosAppVersion);
    if(appVersion < latestCompatibleVersion) {
      needUpgrade = true;
      showDialog(
        context: context,
        builder: (context) {
          return UpgradeDialog();
        }
      );
    }
  }

  static Future<bool> check() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    GetAppVersionRes response = await appConfigApiManager.getAppVersion();
    if(response.version == null) {
      return false;
    }

    Version appVersion = Version.parse(packageInfo.version);
    Version latestCompatibleVersion = Platform.isAndroid? Version.parse(response.version!.androidAppVersion) : Version.parse(response.version!.iosAppVersion);
    if(appVersion < latestCompatibleVersion) {
      needUpgrade = true;
      return false;
    }
    return true;
  }

  static Future<void> upgrade() async {
    final appId = Platform.isAndroid ? 'com.sharevoice' : '6468426325';
    final url = Uri.parse(
      Platform.isAndroid
        ? "market://details?id=$appId"
        : "https://apps.apple.com/app/id$appId",
    );
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }
}