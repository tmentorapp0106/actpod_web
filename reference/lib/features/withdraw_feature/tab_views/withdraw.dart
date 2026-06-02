import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/withdraw_feature/components/withdraw/agreement.dart';
import 'package:quick_share_app/features/withdraw_feature/components/withdraw/tooltip.dart';
import 'package:quick_share_app/features/withdraw_feature/controllers/withdraw_controller.dart';
import 'package:quick_share_app/features/withdraw_feature/pages/fill_in_withdraw_info.dart';
import 'package:quick_share_app/features/withdraw_feature/providers.dart';
import 'package:quick_share_app/providers.dart';

class WithdrawTabView extends ConsumerWidget {
  final int _podcash;
  final TextEditingController _emailEditingController;
  final TextEditingController _phoneEditingController;
  final WithdrawController _withdrawController;
  final TabController tabController;

  WithdrawTabView(
    this._podcash,
    this._emailEditingController,
    this._phoneEditingController,
    this._withdrawController,
    this.tabController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/podcash.png",
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '您可提領的 Podcash',
                      style: TextStyle(
                        fontSize: 14.w
                      ),
                    ),
                    SizedBox(width: 4),
                    WithdrawTooltip(),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ref.watch(userPodCashProvider).toString(),
                    style: TextStyle(fontSize: 40.w, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: ref.watch(withdrawAgreementProvider),
                      activeColor: ConfigColor.primaryDefault,
                      onChanged: (value) {
                        ref.watch(withdrawAgreementProvider.notifier).state = value?? false;
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '我已閱讀並同意',
                              style: TextStyle(
                                color: Colors.black
                              )
                            ),
                            TextSpan(
                              text: '提領條款同意書',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return WithdrawAgreement();
                                    }
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 100.h,)
              ],
            ),
          )
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 96.h,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              color: Colors.white,
            ),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: ElevatedButton(
              onPressed: ref.watch(withdrawAgreementProvider)
                ? () async {
                    ref.watch(withdrawAgreementProvider.notifier).state = false;
                    ref.watch(withdrawReadProvider.notifier).state = false;
                    final success = await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FillInWithdrawInfoPage(_podcash, _emailEditingController, _phoneEditingController, _withdrawController),
                    ));
                    if(success != null && success) {
                      ref.watch(emailTextProvider.notifier).state = "";
                      ref.watch(phoneTextProvider.notifier).state = "";
                      await _withdrawController.getWithdraws();
                      tabController.animateTo(1);
                    }
                  }
            : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ConfigColor.primaryDefault,
                minimumSize: Size.fromHeight(48),
                disabledBackgroundColor: Color(0xffe7e7e7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.w),
                ),
              ),
              child: Text(
                '提領申請',
                style: TextStyle(
                  fontSize: 16.w,
                  color: Colors.black,
                ),
              ),
            ),
          )
        )
      ]
    );
  }
}