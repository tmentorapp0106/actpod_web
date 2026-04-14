import 'package:actpod_web/api_manager/purchase_dto/get_user_purses.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'abstractApiManager.dart';


final purchaseApiManager = PurchaseSystemApi(systemName: "PURCHASE_SERVER_URL");

class PurchaseSystemApi extends AbstractApiManager {
  PurchaseSystemApi({required String systemName}) : super(systemName: systemName);

  Future<GetUserPursesRes> getUserPurses() async {
    Response response = await handelGetWithUserToken("/coinsAndCash/purses");
    return GetUserPursesRes.fromJson(response.data);
  }
}