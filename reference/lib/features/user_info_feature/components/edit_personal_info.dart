import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/features/podcast_store_feature/screens/create_podcast_store.dart';
import 'package:quick_share_app/features/podcast_store_feature/screens/update_podcast_store.dart';
import 'package:quick_share_app/features/user_info_edit_feature/user_info_edit_screen.dart';
import '../../../l10n/app_localizations.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/membership_controller.dart';
import 'package:quick_share_app/features/user_info_feature/screens/subscription_screen.dart';

import '../../../providers.dart';
import '../../../router.dart';
import '../../../services/user_service.dart';
import '../../login_feature/login_screen.dart';
import '../controllers/channel_controller.dart';
import '../controllers/coins_and_cash_controller.dart';
import '../controllers/story_controller.dart';
import '../controllers/user_info_controller.dart';
import '../providers.dart';
import 'option_bottom_sheet.dart';

class EditPersonalInfo extends ConsumerWidget {
  final UserInfoController userInfoController;
  final MembershipController membershipController;

  EditPersonalInfo(this.userInfoController, this.membershipController, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(loginStatusProvider)? loggedIn(context, ref) : notYetLogedIn(ref, context);
  }

  Widget notYetLogedIn(WidgetRef ref, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return LoginPageScreen();
                }
              );
            },
            style: TextButton.styleFrom(
              fixedSize: Size(300.w, 40.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: ConfigColor.backgroundThird,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.w), // Set the border radius here
              ),
            ),
            child: Text(
              "登入/註冊",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp
              ),
            ),
          ),
        ],
      )
    );
  }
  
  Widget loggedIn(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return UserInfoEditScreen();
                    },
                  ),
                );
                userInfoController.getUserInfo();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.only(bottom: 2.h),
                minimumSize: Size(0, 40.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1.w,
                    color: DesignSystem.textColorGrey,
                  ),
                  borderRadius: BorderRadius.circular(16.w),
                ),
              ),
              child: Text(
                "編輯資訊",
                style: TextStyle(
                  color: ConfigColor.textColorDefault,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
          Visibility(
            visible: ref.watch(existPodcastStoreProvider) != null,
            child: SizedBox(width: 10.w)
          ),
          Visibility(
            visible: ref.watch(existPodcastStoreProvider) != null,
            child: Expanded(
              child: TextButton(
                onPressed: () async {
                  final exist = ref.read(existPodcastStoreProvider);
                  if(exist!) {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return UpdatePodcastStoreScreen();
                        },
                      ),
                    );
                  } else {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return CreatePodcastStoreScreen();
                        },
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.only(bottom: 2.h),
                  minimumSize: Size(0, 40.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1.w,
                      color: DesignSystem.textColorGrey,
                    ),
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                ),
                child: Text(
                  "我的Podcast Store",
                  style: TextStyle(
                    color: ConfigColor.textColorDefault,
                    fontSize: 16.sp,
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