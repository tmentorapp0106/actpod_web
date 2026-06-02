import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/exciption_api_dto/insert_exception_log_res.dart';

import 'abstractApiManager.dart';

final exceptionApiManager = ExceptionApiManager(systemName: "EXCEPTION_SERVER_URL");

class ExceptionApiManager extends AbstractApiManager {
  ExceptionApiManager({required String systemName})
      : super(systemName: systemName);

  Future<InsertExceptionLogRes> insertExceptionLog(String deviceType, String functionName, String errorMessage) async {
    var data = {
      "deviceType": deviceType,
      "functionName": functionName,
      "errorMessage": errorMessage
    };

    Response response = await handelPost("/exception/app", data);
    return InsertExceptionLogRes.fromJson(response.data);
  }
}