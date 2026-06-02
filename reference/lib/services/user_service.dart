import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/exist_podcast_store_res.dart';
import 'package:quick_share_app/apiManagers/channel_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/notification_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/create_new_user_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_member_res.dart';
import 'package:quick_share_app/apiManagers/user_system_api_manager.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:quick_share_app/features/voice_message_notice_page_feature/providers.dart';
import 'package:quick_share_app/local_storage/repositories/notification_voice_message_repository.dart';
import 'package:quick_share_app/local_storage/repositories/story_repository.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/language_service.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/shared_prefs/user_prefs.dart';

import '../apiManagers/purchase_api_dto/get_user_purses_res.dart';
import '../apiManagers/purchase_system_api_manager.dart';
import '../apiManagers/user_api_dto/get_user_info_res.dart';

class UserService {
  static Future<CreateNewUserResData> thirdPartyCreateUserOrLogin(String firebaseToken, String? email, String nickname) async {
    CreateNewUserRes res = await userApiManager.thirdPartyCreateUserOrLogin(firebaseToken, email, nickname);
    if(res.code != "0000") {
      throw Exception("failed to create a user");
    }

    await UserPrefs.setUserToken(res.data!.userToken);
    await UserPrefs.setRefreshToken(res.data!.refreshToken);
    return res.data!;
  }

  static Future<CreateNewUserResData> emailSignup(String email, String password, String nickname) async {
    CreateNewUserRes res = await userApiManager.emailSignup(email, password, nickname);
    if(res.code != "0000") {
      ToastService.showNoticeToast(res.message);
      throw Exception(res.message);
    }

    await UserPrefs.setUserToken(res.data!.userToken);
    await UserPrefs.setRefreshToken(res.data!.refreshToken);
    return res.data!;
  }

  static Future<CreateNewUserResData> emailLogin(String email, String password) async {
    CreateNewUserRes res = await userApiManager.emailLogin(email, password);
    if(res.code != "0000") {
      ToastService.showNoticeToast(res.message);
      throw Exception(res.message);
    }

    await UserPrefs.setUserToken(res.data!.userToken);
    await UserPrefs.setRefreshToken(res.data!.refreshToken);
    return res.data!;
  }

  static String? getUserToken() {
    String? userToken = UserPrefs.getUserToken();
    return userToken;
  }

  static bool hasLoggedIn() {
    if(getUserToken() == null || getUserToken() == "") {
      return false;
    }
    return true;
  }

  static Future<void> loadUserInfo(WidgetRef? ref) async {
    GetUserInfoRes userInfoRes = await userApiManager.getUserInfo();
    if(userInfoRes.code != "0000") {
      throw Exception("failed to get user info");
    }

    GetMemberRes membershipRes = await userApiManager.getMembership();
    if(membershipRes.code != "0000") {
      throw Exception("failed to get membership info");
    }
    GetUserPursesRes pursesRes = await purchaseApiManager.getUserPurses();

    if(userInfoRes.userInfo != null) {
      ExistPodcastStoreRes existPodcastStoreRes = await channelApiManager.existPodcastStore(userInfoRes.userInfo!.userId);
      if(ref != null) {
        ref.watch(existPodcastStoreProvider.notifier).state = existPodcastStoreRes.exist;
      }
    }

    await UserPrefs.setMembership(membershipRes.memberInfo!.customerLevel);
    await UserPrefs.setUserInfo(userInfoRes.userInfo);
    if(ref != null) {
      ref.watch(selfMembershipProvider.notifier).state = membershipRes.memberInfo;
      ref.watch(userPodCoinsProvider.notifier).state = pursesRes.purses == null? 0 : pursesRes.purses!.coinsPurse.podCoins;
      ref.watch(userPodCashProvider.notifier).state = pursesRes.purses == null? 0 : pursesRes.purses!.cashPurse.podCash;
    }
  }

  static Future<void> reloadUserPurses(WidgetRef ref) async {
    GetUserPursesRes pursesRes = await purchaseApiManager.getUserPurses();
    ref.watch(userPodCoinsProvider.notifier).state = pursesRes.purses == null? 0 : pursesRes.purses!.coinsPurse.podCoins;
    ref.watch(userPodCashProvider.notifier).state = pursesRes.purses == null? 0 : pursesRes.purses!.cashPurse.podCash;
  }

  static UserInfoDto? getUserInfo() {
    return UserPrefs.getUserInfo();
  }

  static Future<UserInfoDto?> getOtherUserInfo(String userId) async {
    GetUserInfoRes otherUserInfoRes = await userApiManager.getOthersUserInfo(userId);
    if(otherUserInfoRes.code != "0000") {
      throw Exception("faild to get other user info");
    }
    return otherUserInfoRes.userInfo;
  }

  static Future<void> updateUserInfo(WidgetRef ref, String username, String nickname, String selfDescription, String email) async {
    UserInfoDto? userInfo = UserPrefs.getUserInfo();
    await userApiManager.editUserInfo(username, nickname, email, userInfo!.gender, selfDescription);
    await loadUserInfo(ref);
  }

  static Future<void> updateUserAvatar(WidgetRef ref, File userAvatarFile) async {
    await userApiManager.changeUserAvatar(userAvatarFile);
    await loadUserInfo(ref);
  }

  static Future<void> logoutUser(WidgetRef? ref) async {
    PurchaseSystemApi.logout();
    notificationVoiceMessageRepository.removeAllMessages();
    storyRepository.removeAllStories();
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if(UserService.getUserInfo() != null) {
      storyRepository.removeStoriesByUserId(UserService.getUserInfo()!.userId);
      await notificationApiManager.removeToken(UserService.getUserInfo()!.userId, fcmToken);
    }
    await UserPrefs.cleanUser();
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();

    if(ref != null) {
      ref.watch(localeProvider.notifier).state = LanguageService.loadLanguage();
      ref.watch(loginStatusProvider.notifier).state = false;
      ref.watch(selfUserInfoProvider.notifier).state = null;
      ref.watch(userPodCoinsProvider.notifier).state = 0;
      ref.watch(userPodCashProvider.notifier).state = 0;
      ref.watch(selfStoryListProvider.notifier).state = null;
      ref.watch(selfMembershipProvider.notifier).state = null;
      ref.watch(selfStoryCountProvider.notifier).state = 0;
      ref.watch(selfChannelListProvider.notifier).state = [];
      ref.watch(storyVoiceMessageNoticeListProvider.notifier).state = [];
      ref.watch(listenedVoiceMessageNoticeListProvider.notifier).state = [];
      ref.watch(loadingProvider.notifier).state = false;
    }
  }
}