import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/check_capacity_res.dart';
import 'package:quick_share_app/apiManagers/channel_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/upload_api_dto/get_upload_url_res.dart';
import 'package:quick_share_app/apiManagers/upload_system_api_manager.dart';
import 'package:quick_share_app/dto/channel_dto.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../apiManagers/channel_api_dto/create_channel_res.dart';
import '../../../apiManagers/user_api_dto/search_user_res.dart';
import '../../../apiManagers/user_system_api_manager.dart';

class CreateChannelController {
  WidgetRef _ref;

  CreateChannelController(this._ref);

  Future<bool> createChannel() async {
    if (_ref.watch(createChannelImageProvider) == null) {
      ToastService.showNoticeToast("請選擇圖片");
      return false;
    }
    if (_ref.watch(createChannelNameProvider) == null ||
        _ref.watch(createChannelNameProvider) == "") {
      ToastService.showNoticeToast("請輸入頻道名稱");
      return false;
    }
    if (_ref.watch(createChannelDescriptionProvider) == null ||
        _ref.watch(createChannelDescriptionProvider) == "") {
      ToastService.showNoticeToast("請輸入頻道敘述");
      return false;
    }

    CheckCapacityRes checkRes = await channelApiManager.checkCapacity();
    if (checkRes.code != "0000") {
      ToastService.showNoticeToast(checkRes.message);
      return false;
    }

    _ref.watch(loadingProvider.notifier).state = true;
    try {
      GetUploadUrlRes uploadImageRes = await uploadApiManager
          .uploadChannelImage(_ref.watch(createChannelImageProvider)!);
      if (uploadImageRes.code != "0000") {
        ToastService.showNoticeToast(uploadImageRes.message);
        return false;
      }
      CreateChannelRes createChannelRes = await channelApiManager.createChannel(
          _ref.watch(createChannelNameProvider)!,
          _ref.watch(createChannelDescriptionProvider)!,
          uploadImageRes.data!.publicUrl,
          _ref.read(channelCoOwnersProvider).map((user) => user.userId).toList()
      );
      if (createChannelRes.code != "0000") {
        ToastService.showNoticeToast(createChannelRes.message);
        return false;
      }

      ChannelDto newChannel = ChannelDto(
          createChannelRes.channelId,
          UserService.getUserInfo()!.userId,
          _ref.read(channelCoOwnersProvider).map((user) => user.userId).toList(),
          UserService.getUserInfo()!.nickname,
          UserService.getUserInfo()!.avatarUrl,
          _ref.watch(createChannelDescriptionProvider)!,
          _ref.watch(createChannelNameProvider)!,
          uploadImageRes.data!.publicUrl,
          0,
          DateTime.now());
      List<ChannelDto> channelList = _ref.watch(selfChannelListProvider) ?? [];
      channelList.insert(0, newChannel);
      _ref.watch(selfChannelListProvider.notifier).state = [...channelList];
      _ref.watch(createChannelNameProvider.notifier).state = null;
      _ref.watch(createChannelDescriptionProvider.notifier).state = null;
      _ref.watch(createChannelImageProvider.notifier).state = null;
    } catch (e) {
      _ref.watch(loadingProvider.notifier).state = false;
      print(e);
      return false;
    }
    _ref.watch(loadingProvider.notifier).state = false;
    return true;
  }

  Future<void> searchUserList(String nickname) async {
    if(nickname == "") {
      _ref.watch(searchUserListProvider.notifier).state = [];
      return;
    }
    _ref.watch(searchUserListProvider.notifier).state = null;
    SearchUserRes response = await userApiManager.searchUser(nickname);
    if(response.code != "0000") {
      _ref.watch(searchUserListProvider.notifier).state = [];
      return;
    }
    _ref.watch(searchUserListProvider.notifier).state = response.userInfoList;
  }
}
