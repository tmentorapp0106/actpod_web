import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_app_version_res.dart';

import 'abstractApiManager.dart';

final appConfigApiManager = VersionApiManager(systemName: "APP_CONFIG_SERVER_URL");

class VersionApiManager extends AbstractApiManager {

  VersionApiManager({required String systemName})
      : super(systemName: systemName);

  Future<GetAppVersionRes> getAppVersion() async {
    Response response = await handelGet("/version/app/v2");
    return GetAppVersionRes.fromJson(response.data);
  }
}