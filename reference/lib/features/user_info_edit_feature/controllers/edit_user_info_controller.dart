import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_union_code_res.dart';
import 'package:quick_share_app/apiManagers/user_system_api_manager.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/features/user_info_edit_feature/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/shared_prefs/user_prefs.dart';
import 'package:quick_share_app/utils/image_utils.dart';

import '../../../apiManagers/user_api_dto/get_user_info_res.dart';
import '../../../services/user_service.dart';

class EditUserInfoController {
  final WidgetRef _ref;
  final TextEditingController _usernameTextController;
  final TextEditingController _nicknameTextController;
  final TextEditingController _bioTextController;
  final TextEditingController _emailTextController;

  EditUserInfoController(this._ref, this._usernameTextController, this._nicknameTextController, this._bioTextController, this._emailTextController);

  void getUserInfo() {
    UserInfoDto userInfo = UserService.getUserInfo()!;
    _ref.watch(userInfoProvider.notifier).state = userInfo;
    _usernameTextController.text = userInfo.username;
    _nicknameTextController.text = userInfo.nickname;
    _bioTextController.text = userInfo.selfDescription;
    _emailTextController.text = userInfo.email;
  }

  Future<void> getUnionCode() async {
    GetUnionCodeRes resp = await userApiManager.getUnionCode();
    if(resp.code == "0000") {
      _ref.watch(unionCodeProvider.notifier).state = resp.unionCodeDto?.code;
    }
  }

  Future<void> selectNewAvatar() async {
    File? selectFile = await ImageUtils.pickMedia(true, (file) => ImageUtils.cropImageFunc(file, 512, 512));
    if(selectFile != null) {
      await UserService.updateUserAvatar(_ref, selectFile);
      _ref.watch(userInfoProvider.notifier).state = UserPrefs.getUserInfo();
    }
  }

  Future<bool> updateUserInfo() async {
    if(_nicknameTextController.text == "") {
      ToastService.showNoticeToast("請輸入暱稱");
      return false;
    }
    if(_usernameTextController.text == "") {
      ToastService.showNoticeToast("請輸入帳號名稱");
      return false;
    }
    if(_emailTextController.text == "") {
      ToastService.showNoticeToast("請輸入Email");
      return false;
    }

    await UserService.updateUserInfo(_ref, _usernameTextController.text, _nicknameTextController.text, _bioTextController.text, _emailTextController.text);
    _ref.watch(userInfoProvider.notifier).state = UserPrefs.getUserInfo();
    return true;
  }
}