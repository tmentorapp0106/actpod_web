import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:quick_share_app/apiManagers/purchase_api_dto/create_withdraw_res.dart';
import 'package:quick_share_app/apiManagers/purchase_api_dto/get_user_purses_res.dart';
import 'package:quick_share_app/apiManagers/purchase_api_dto/get_withdraws_res.dart';
import 'package:quick_share_app/apiManagers/purchase_api_dto/purchase_coin_res.dart';
import 'package:quick_share_app/apiManagers/purchase_api_dto/purchase_live_room_ticket_res.dart';
import 'package:quick_share_app/apiManagers/purchase_api_dto/update_withdraw_email_phone_res.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import 'abstractApiManager.dart';

class PodCoins{
  static const podCoins50 = "actpod-50-pods";
  static const podCoins100 = "actpod-100-pods";
  static const podCoins500 = "actpod-500-pods";
  static const podCoins300 = "actpod-300-pods";
  static const podCoins1000 = "actpod-1000-pods";

  static const podCoinList = [podCoins50, podCoins100, podCoins300, podCoins500, podCoins1000];
}

final purchaseApiManager = PurchaseSystemApi(systemName: "PURCHASE_SERVER_URL");

class PurchaseSystemApi extends AbstractApiManager {
  PurchaseSystemApi({required String systemName}) : super(systemName: systemName);

  static const _googleApiKey = "goog_llPHBOMEDDpnXDTUPRkNVAYrhhd";
  static const _appleApiKey = "appl_nPJnSrjoWZjajNfPJUHFMTjYOlD";

  static void init() {
    Purchases.setLogLevel(LogLevel.debug);
    if (Platform.isIOS) {
      Purchases.configure(PurchasesConfiguration(_appleApiKey));
    } else if (Platform.isAndroid) {
      Purchases.configure(PurchasesConfiguration(_googleApiKey));
    }
  }

  static void login(String userId) {
    Purchases.logIn(userId);
  }

  static Future<void> logout() async {
    if(!await Purchases.isAnonymous) {
      Purchases.logOut();
      return;
    }
  }

  static Future<List<Offering>> fetchPodCoins() async {
    try {
      final offers = await Purchases.getOfferings();
      return offers.all.values.where((offer) => PodCoins.podCoinList.contains(offer.identifier)).toList();
    } on PlatformException catch (e) {
      print(e);
    }
    return [];
  }

  Future<Offering?> fetchMembership() async {
    try {
      final offers = await Purchases.getOfferings();
      return offers.all.values.where((offer) => offer.identifier == "actpod-membership-c1").first;
    } on PlatformException catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> purchasePodCoins(Package package, Offering offering) async {
    try {
      final purchaseParams = PurchaseParams.package(package);
      final PurchaseResult result = await Purchases.purchase(purchaseParams);

      final CustomerInfo info = result.customerInfo;

      // TODO: check entitlement / process coin grant logic
      // Example:
      // final isActive = info.entitlements.all["podcoins"]?.isActive ?? false;

      return;
    } on PlatformException catch (e) {

      rethrow;
    }
  }

  void openSubscriptionManagement() async {
    String url;

    if (Platform.isAndroid) {
      // Opens Google Play subscription center for your app
      url = "https://play.google.com/store/account/subscriptions";
    } else if (Platform.isIOS) {
      // Opens Apple ID subscription settings
      url = "https://apps.apple.com/account/subscriptions";
    } else {
      throw UnsupportedError("Unsupported platform");
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> purchaseMembership(String offeringId, String? oldOfferingId, String? unionCode) async {
    Offerings offerings = await Purchases.getOfferings();
    Offering? offering = offerings.getOffering(offeringId);
    Map<String, String> attributes = {
      "unionCode": unionCode?? ""
    };
    await Purchases.setAttributes(attributes);
    await Purchases.purchasePackage(
      offering!.availablePackages[0],
      googleProductChangeInfo: oldOfferingId == null? null : GoogleProductChangeInfo(
        oldOfferingId,
        prorationMode: GoogleProrationMode.immediateWithTimeProration
      ),
    );
  }

  Future<GetUserPursesRes> getUserPurses() async {
    Response response = await handelGetWithUserToken("/coinsAndCash/purses");
    return GetUserPursesRes.fromJson(response.data);
  }

  Future<CreateWithdrawRes> createWithdraw(String email, String phone, int podcash) async {
    Response response = await handelPostWithUserToken("/coinsAndCash/withdraw", {
      "email": email,
      "phone": phone,
      "podcash": podcash,
    });
    return CreateWithdrawRes.fromJson(response.data);
  }

  Future<GetWithdrawsRes> getWithdraws() async {
    Response response = await handelGetWithUserToken("/coinsAndCash/withdraws");
    return GetWithdrawsRes.fromJson(response.data);
  }

  Future<UpdateWithdrawEmailPhoneRes> updateWithdrawEmailPhone(String withdrawId, String email, String phone) async {
    Response response = await handelPostWithUserToken("/coinsAndCash/withdraw/updateEmailPhone", {
      "withdrawId": withdrawId,
      "email": email,
      "phone": phone,
    });
    return UpdateWithdrawEmailPhoneRes.fromJson(response.data);
  }

  Future<PurchaseLiveRoomTicketRes> purchaseLiveRoomTicket(String userId, String roomId, String hostId, int podCoins) async {
    var data = {
      "userId": userId,
      "roomId": roomId,
      "hostId": hostId,
      "podCoins": podCoins
    };
    Response response = await handelPostWithUserToken("/coinsAndCash/liveTickets/purchase", data);
    return PurchaseLiveRoomTicketRes.fromJson(response.data);
  }
}