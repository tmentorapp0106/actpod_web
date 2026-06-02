import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/exist_sync_setting_res.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/first_sync_res.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/get_sync_setting_res.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/is_syncing_res.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/manual_sync_res.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/remove_sync_setting_res.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/update_sync_setting_res.dart';

import 'abstractApiManager.dart';

final syncApiManager = SyncApiManager(systemName: "SYNC_SERVER_URL");

class SyncApiManager extends AbstractApiManager {
  SyncApiManager({required String systemName}) : super(systemName: systemName);

  Future<FirstSyncRes> firstSync(String feed, List<String> guids, String channelId, String spaceId) async {
    var data = {
      "feed": feed,
      "guids": guids,
      "channelId": channelId,
      "spaceId": spaceId
    };

    Response response = await handelPostWithUserToken("/first", data);
    return FirstSyncRes.fromJson(response.data);
  }

  Future<ManualSyncRes> manualSync() async {
    Response response = await handelPostWithUserToken("/manual", null);
    return ManualSyncRes.fromJson(response.data);
  }

  Future<UpdateSyncSettingRes> updateSyncSetting(String channelId, String spaceId) async {
    var data = {
      "channelId": channelId,
      "spaceId": spaceId
    };

    Response response = await handelPostWithUserToken("/updateSetting", data);
    return UpdateSyncSettingRes.fromJson(response.data);
  }
  
  Future<IsSyncingRes> isSyncing() async {
    Response response = await handelGetWithUserToken("/isSyncing");
    return IsSyncingRes.fromJson(response.data);
  }

  Future<ExistSyncSettingRes> existSyncSetting() async {
    Response response = await handelGetWithUserToken("/existSetting");
    return ExistSyncSettingRes.fromJson(response.data);
  }

  Future<GetSyncSettingRes> getSyncSetting() async {
    Response response = await handelGetWithUserToken("/syncSetting");
    return GetSyncSettingRes.fromJson(response.data);
  }

  Future<RemoveSyncSettingRes> removeSyncSetting() async {
    Response response = await handelPostWithUserToken("/removeSetting", null);
    return RemoveSyncSettingRes.fromJson(response.data);
  }
}