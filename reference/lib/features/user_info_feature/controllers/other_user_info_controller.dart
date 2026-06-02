import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_user_info_res.dart';
import 'package:quick_share_app/apiManagers/user_system_api_manager.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../utils/image_utils.dart';

class OtherUserInfoController {
  WidgetRef ref;
  UserInfoDto? otherInfo;
  OtherUserInfoController(this.ref);

  Future<void> getOtherUserInfo(String userId) async {
    UserInfoDto? otherUserInfo = await UserService.getOtherUserInfo(userId);
    ref.watch(otherUserInfoProvider.notifier).state = otherUserInfo;
    otherInfo = otherUserInfo;
  }
}