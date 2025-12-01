import 'package:actpod_web/api_manager/user_api_manager.dart';
import 'package:actpod_web/api_manager/user_dto/get_user_info.dart';
import 'package:actpod_web/features/personal_page/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserController {
  WidgetRef ref;

  UserController({required this.ref});

  Future<void> getOtherUserInfo(String userId) async {
    GetUserInfoRes otherUserInfoRes = await userApiManager.getOthersUserInfo(userId);
    if(otherUserInfoRes.code != "0000") {
      throw Exception("faild to get other user info");
    }
    ref.watch(userInfoProvider.notifier).state = otherUserInfoRes.userInfo;
  }
}