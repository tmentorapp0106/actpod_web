import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/apiManagers/purchase_system_api_manager.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/user_info_feature/components/logout_dialog.dart';
import 'package:quick_share_app/features/user_info_feature/components/remove_account_dialog.dart';
import 'package:quick_share_app/features/user_info_feature/components/select_region_page.dart';
import 'package:quick_share_app/router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../l10n/app_localizations.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';

import '../../../providers.dart';
import '../../../services/user_service.dart';
import '../../login_feature/login_screen.dart';
import '../../podcast_store_feature/screens/create_podcast_store.dart';

class OptionBottomSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(selfMembershipProvider);
    return Padding(
      padding: EdgeInsets.only(top: 15.h, bottom: ref.watch(mainPlayerStoryInfoProvider) == null? 80.h : 150.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          share(ref, context),
          manageSubscription(membership?.customerLevel),
          logout(ref, context),
          block(ref, context),
          report(ref, context),
          removeAccount(ref, context)
        ]
      )
    );
  }

  Widget manageSubscription(String? membership) {
    return Visibility(
      visible: membership != "Free" && membership != null,
      child: InkWell(
        onTap: () async {
          purchaseApiManager.openSubscriptionManagement();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
          child: Row(
            children: [
              Text(
                "管理訂閱",
                style: TextStyle(
                  fontSize: 18.sp,
                ),
              )
            ],
          ),
        )
      )
    );
  }

  Widget changeRegion(BuildContext context) {
    return InkWell(
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SelectRegionPage(),
        ));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
        child: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.changeRegion,
              style: TextStyle(
                fontSize: 18.sp,
              ),
            )
          ],
        ),
      )
    );
  }

  Widget logout(WidgetRef ref, BuildContext context) {
    return Visibility(
      visible: ref.watch(loginStatusProvider),
      child: InkWell(
        onTap: () async {
          showDialog(
            context: context,
            builder: (context) {
              return LogoutDialog();
            }
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
          child: Row(
            children: [
              Text(
                "登出",
                style: TextStyle(
                  fontSize: 18.sp,
                ),
              )
            ],
          ),
        )
      )
    );
  }

  Widget share(WidgetRef ref, BuildContext context) {
    return Visibility(
        visible: ref.watch(loginStatusProvider),
        child: InkWell(
            onTap: () async {
              final box = context.findRenderObject() as RenderBox?;
              SharePlus.instance.share(
                ShareParams(
                  text: 'https://web.actpodapp.com/personal/${UserService.getUserInfo()?.userId}?openExternalBrowser=1',
                  sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                )
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
              child: Row(
                children: [
                  Text(
                    "分享個人頁面",
                    style: TextStyle(
                      fontSize: 18.sp,
                    ),
                  )
                ],
              ),
            )
        )
    );
  }

  Widget removeAccount(WidgetRef ref, BuildContext context) {
    return Visibility(
      visible: ref.watch(loginStatusProvider),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return RemoveAccountDialog();
            }
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
          child: Row(
            children: [
              Text(
                "移除帳號",
                style: TextStyle(
                    fontSize: 18.sp,
                    color: ConfigColor.redDefault
                ),
              )
            ],
          ),
        )
      )
    );
  }

  Widget report(WidgetRef ref, BuildContext context) {
    return InkWell(
        onTap: () {
          router.push("/report");
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
          child: Row(
            children: [
              Text(
                "遞交檢舉",
                style: TextStyle(
                    fontSize: 18.sp,
                    color: ConfigColor.redDefault
                ),
              )
            ],
          ),
        )
    );
  }

  Widget block(WidgetRef ref, BuildContext context) {
    return InkWell(
        onTap: () {
          if(!UserService.hasLoggedIn()) {
            showDialog(
              context: context,
              builder: (context) {
                return LoginPageScreen();
              }
            );
            return;
          }
          router.push("/block");
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
          child: Row(
            children: [
              Text(
                "封鎖其他使用者",
                style: TextStyle(
                  fontSize: 18.sp,
                  color: ConfigColor.redDefault
                ),
              )
            ],
          ),
        )
    );
  }
}