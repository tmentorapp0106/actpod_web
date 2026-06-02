import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/withdraw_feature/controllers/withdraw_controller.dart';

import '../../../config/color.dart';
import '../providers.dart';

class UpdateWithdrawInfoPage extends ConsumerWidget {
  final String withdrawId;
  final TextEditingController _emailEditingController;
  final TextEditingController _phoneEditingController;
  final WithdrawController _withdrawController;

  UpdateWithdrawInfoPage(
    this.withdrawId,
    this._emailEditingController,
    this._phoneEditingController,
    this._withdrawController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '修改提領資料',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // extra bottom padding to avoid overlap
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.email_outlined, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('請填寫您的收件信箱'),
                  ],
                ),
                SizedBox(height: 4.h),
                TextField(
                  controller: _emailEditingController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    ref.watch(emailTextProvider.notifier).state = value;
                    ref.watch(phoneTextProvider.notifier).state = _phoneEditingController.text;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: ref.watch(emailTextProvider).isNotEmpty
                        ? IconButton(
                      icon: const Icon(
                          Icons.cancel
                      ),
                      onPressed: () {
                        _emailEditingController.text = "";
                        ref.watch(emailTextProvider.notifier).state = "";
                      },
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '我們將寄送提領申請資料至該信箱',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                SizedBox(height: 20.h),

                const Row(
                  children: [
                    Icon(Icons.phone_android_rounded, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('請填寫您的手機號碼'),
                  ],
                ),
                SizedBox(height: 4.h),
                TextField(
                  controller: _phoneEditingController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    ref.watch(phoneTextProvider.notifier).state = value;
                    ref.watch(emailTextProvider.notifier).state = _emailEditingController.text;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: ref.watch(phoneTextProvider).isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        _phoneEditingController.text = "";
                        ref.watch(phoneTextProvider.notifier).state = "";
                      },
                    ) : null,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '我們將使用該手機號碼與您聯絡',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Positioned(
              bottom: 0,
              left: 16,
              right: 16,
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
                  onPressed: ref.watch(emailTextProvider) != "" && ref.watch(phoneTextProvider) != ""
                      ? () async {
                    try {
                      await _withdrawController.updateEmailPhone(
                        withdrawId,
                        ref.watch(emailTextProvider),
                        ref.watch(phoneTextProvider)
                      );
                    } catch(e) {
                      return;
                    }
                    await _withdrawController.getWithdraws();
                    if(context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConfigColor.primaryDefault,
                    minimumSize: Size.fromHeight(48),
                    disabledBackgroundColor: Color(0xffe7e7e7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.w),
                    ),
                  ),
                  child: Text(
                    '修改資料',
                    style: TextStyle(
                      fontSize: 16.w,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }
}