import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/report_api_dto/create_report_res.dart';

import 'abstractApiManager.dart';

final reportApiManager = ReportApiManager(systemName: "REPORT_SERVER_URL");

class ReportApiManager extends AbstractApiManager {

  ReportApiManager({required String systemName}) : super(systemName: systemName);

  Future<CreateReportRes> createReport(String reporterId, String suspectsId, String reportType, String description) async {
    var postData = {
      "reporterId": reporterId,
      "suspectsId": suspectsId,
      "reportType": reportType,
      "description": description
    };

    Response response = await handelPost("/create", postData);
    return CreateReportRes.fromJson(response.data);
  }
}