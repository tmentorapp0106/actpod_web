import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/purchase_api_dto/get_withdraws_res.dart';
import 'package:quick_share_app/apiManagers/purchase_system_api_manager.dart';
import 'package:quick_share_app/features/withdraw_feature/providers.dart';

import '../../../apiManagers/purchase_api_dto/create_withdraw_res.dart';
import '../../../apiManagers/purchase_api_dto/update_withdraw_email_phone_res.dart';

class WithdrawController {
  WidgetRef ref;
  WithdrawController(this.ref);

  Future<void> getWithdraws() async {
    GetWithdrawsRes response = await purchaseApiManager.getWithdraws();
    if(response.code != "0000") {
      throw Exception("Failed to fetch withdraws: ${response.message}");
    }
    ref.watch(withdrawsProvider.notifier).state = response.withdraws ?? [];
  }

  Future<void> updateEmailPhone(String withdrawId, String email, String phone) async {
    UpdateWithdrawEmailPhoneRes response = await purchaseApiManager.updateWithdrawEmailPhone(withdrawId, email, phone);
    if(response.code != "0000") {
      throw Exception("Failed to update withdraw info: ${response.message}");
    }
  }

  Future<void> createWithdraw(String email, String phone, int podcash) async {
    CreateWithdrawRes response = await purchaseApiManager.createWithdraw(email, phone, podcash);
    if(response.code != "0000") {
      throw Exception(response.message);
    }
  }
}