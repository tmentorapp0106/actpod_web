import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/withdraw_feature/components/history/card.dart';
import 'package:quick_share_app/features/withdraw_feature/components/history/title.dart';
import 'package:quick_share_app/features/withdraw_feature/controllers/withdraw_controller.dart';
import 'package:quick_share_app/features/withdraw_feature/providers.dart';

class WithdrawHistoryTabView extends ConsumerWidget {
  final TextEditingController emailTextController;
  final TextEditingController phoneTextController;
  final WithdrawController withdrawController;

  WithdrawHistoryTabView(
    this.emailTextController,
    this.phoneTextController,
    this.withdrawController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawHistory = ref.watch(withdrawsProvider);
    if (withdrawHistory.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: WithdrawHistoryTitle(),
          ),
          SizedBox(height: 200.h,),
          Center(
            child: Text(
              '目前沒有提領紀錄',
              style: TextStyle(fontSize: 16.w, color: Colors.grey),
            )
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: withdrawHistory.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const WithdrawHistoryTitle();
        }

        final history = withdrawHistory[index - 1];
        return WithdrawCard(
          withdraw: history,
          emailEditingController: emailTextController,
          phoneEditingController: phoneTextController,
          withdrawController: withdrawController,
        );
      },
    );
  }
}