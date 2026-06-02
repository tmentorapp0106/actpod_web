import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_block_users_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/search_user_res.dart';
import 'package:quick_share_app/apiManagers/user_system_api_manager.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedUserProvider = StateProvider.autoDispose<UserInfoDto?>((ref) => null);
final searchKeywordProvider = StateProvider.autoDispose<String>((ref) => "");
final searchResultsProvider = FutureProvider.autoDispose<List<UserInfoDto>>((ref) async {
  final keyword = ref.watch(searchKeywordProvider);
  // 關鍵字空就不打 API，避免浪費
  if (keyword.trim().isEmpty) return const [];
  SearchUserRes response = await userApiManager.searchUser(keyword);
  if(response.code != "0000") {
    return const [];
  }
  return response.userInfoList?? [];
});
final blockedUsersProvider = FutureProvider.autoDispose<List<UserInfoDto>>((ref) async {
  GetBlockUsersRes response = await userApiManager.getBlockedUsers();
  if(response.code != "0000") {
    return const [];
  }
  return response.userInfoList;
});