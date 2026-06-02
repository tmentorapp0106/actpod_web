import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/apiManagers/purchase_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/user_system_api_manager.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/design_system/components/podcoin.dart';
import 'package:quick_share_app/dto/membership_level_info_dto.dart';
import 'package:quick_share_app/features/user_info_feature/components/subscription/terms.dart';
import 'package:quick_share_app/features/user_info_feature/components/subscription/union_code_dialog.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../apiManagers/user_api_dto/get_union_code_by_code_res.dart';
import '../../../dto/membership_dto.dart';
import '../../../providers.dart';
import '../../../services/toast_service.dart';

class SubscriptionScreen extends ConsumerWidget {

  void onTermsTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SubscriptionTerms();
      }
    );
  }

  void onPrivacyTap(BuildContext context) {
    launchUrl(
        Uri.parse("https://www.privacypolicies.com/live/a3909f32-ebda-440c-81fd-653101238f58"),
        mode: LaunchMode.inAppBrowserView
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipLevelInfos = ref.watch(membershipLevelInfosProvider);
    final membership = ref.watch(selfMembershipProvider);
    MembershipLevelInfoDto? oldMembershipLevelInfo;
    if(membership != null && membership.customerLevel != "Free") {
      for(MembershipLevelInfoDto info in membershipLevelInfos!) {
        if(info.title == "${membership.customerLevel} 會員") {
          oldMembershipLevelInfo = info;
        }
      }
    }

    if(membershipLevelInfos == null) {
      return Center(child: CircularProgressIndicator(
        color: DesignColor.primary50,
      ));
    }

    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: ScreenUtil().screenHeight
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "升級 ActPod 會員方案，\n解鎖更多功能、將 Podcoin 變現！",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.bold
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: '訂閱即表示您已同意',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(
                            text: ' ',
                          ),
                          TextSpan(
                            text: '使用者條款',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () => onTermsTap(context),
                          ),
                          const TextSpan(
                            text: ' 及 ',
                          ),
                          TextSpan(
                            text: '隱私權政策',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () => onPrivacyTap(context),
                          ),
                        ],
                      ),
                    ),
                    ...membershipLevelInfos.map((info) => caseDisplay(context, ref, info, oldMembershipLevelInfo, membership)).toList(),
                    SizedBox(height: 16.h,)
                  ]
                )
              )
            )
          ),
        )
      )
    );
  }

  Widget caseDisplay(BuildContext context, WidgetRef ref, MembershipLevelInfoDto membershipInfo, MembershipLevelInfoDto? oldMembershipInfo, MembershipDto? membership) {
    List<Widget> contents = [];
    for(String content in membershipInfo.contents) {
      contents.add(_buildItem(content));
    }

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(
          width: 1,
          color: DesignColor.neutral100
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(membershipInfo.title, style: TextStyle(fontSize: 20.w, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "＄",
                    style: TextStyle(fontSize: 12.w, color: DesignColor.neutral300),
                  ),
                  TextSpan(
                    text: "${membershipInfo.price}", // or formatted price
                    style: TextStyle(
                      fontSize: 24.w,        // bigger for the price
                      color: Colors.black,   // keep price black
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " NTD / 月",
                    style: TextStyle(fontSize: 12.w, color: DesignColor.neutral300),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Visibility(
              visible: membershipInfo.price != 0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: membership != null && membershipInfo.customerLevel == membership.customerLevel? DesignColor.neutral50 : DesignColor.primary50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.w),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 16.w),
                  minimumSize: Size(0, 24.w),
                ),
                onPressed: membership != null && membershipInfo.customerLevel == membership.customerLevel? null : () async {
                  ref.watch(loadingProvider.notifier).state = true;
                  try {
                    await purchaseApiManager.purchaseMembership(membershipInfo.androidId, oldMembershipInfo?.androidId, membership?.unionCode);
                  } on PlatformException catch (e) {
                    if(e.code == "1") { // cancel purchase
                      ref.watch(loadingProvider.notifier).state = false;
                      return;
                    }
                    ToastService.showNoticeToast("購買失敗");
                    ref.watch(loadingProvider.notifier).state = false;
                    return;
                  } catch(e) {
                    ToastService.showNoticeToast("購買失敗");
                    ref.watch(loadingProvider.notifier).state = false;
                    return;
                  }
                  ref.watch(loadingProvider.notifier).state = false;
                  Navigator.of(context).pop(true);
                  ToastService.showSuccessToast("訂閱成功！您已成為 ActPod 會員");
                },
                child: Center(
                  child: Text(
                      membership != null && membershipInfo.customerLevel == membership.customerLevel? "目前的方案" : "訂閱",
                    style: TextStyle(
                      color: membership != null && membershipInfo.customerLevel == membership.customerLevel? DesignColor.neutral500 : DesignColor.neutral950,
                      fontSize: 14.sp
                    )
                  ),
                )
              )
            ),
            SizedBox(height: 8.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...contents
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget priceWidget(WidgetRef ref) {
    final price = ref.watch(membershipPriceProvider);
    Widget priceWidget = price == null
        ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(color: DesignColor.primary50, strokeWidth: 2),
        )
        : Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${ref.watch(membershipPriceProvider)} / 月  ',
            style: TextStyle(
              fontSize: 14.w,
              color: Colors.black,
              fontWeight: FontWeight.bold, // or any style you prefer
            ),
          ),
          TextSpan(
            text: '可隨時取消',
            style: TextStyle(
              fontSize: 12.w,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
    return priceWidget;
  }

  Widget _buildItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          PodCoin(size: 20.w,),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
            )
          ),
        ],
      ),
    );
  }
}