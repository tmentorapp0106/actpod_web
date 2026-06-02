import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:quick_share_app/apiManagers/purchase_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/get_member_level_infos_res.dart';

import '../../../apiManagers/user_api_dto/get_member_res.dart';
import '../../../apiManagers/user_system_api_manager.dart';
import '../providers.dart';

class MembershipController {
  WidgetRef ref;

  MembershipController(this.ref);

  Future<void> getMembership() async {
    GetMemberRes membershipRes = await userApiManager.getMembership();
    if(membershipRes.code != "0000") {
      throw Exception("failed to get membership info");
    }
    ref.watch(selfMembershipProvider.notifier).state = membershipRes.memberInfo;
  }

  Future<void> getMembershipPrice() async {
    Offering? offering = await purchaseApiManager.fetchMembership();
    ref.watch(membershipPriceProvider.notifier).state = offering?.availablePackages[0].storeProduct.priceString;
  }

  Future<void> getMembershipLevelInfos() async {
    GetMemberLevelInfosRes response = await userApiManager.getMembershipLevelInfos();
    if(response.code != "0000") {
      return;
    }
    ref.watch(membershipLevelInfosProvider.notifier).state = response.membershipLevelInfo;
  }
}