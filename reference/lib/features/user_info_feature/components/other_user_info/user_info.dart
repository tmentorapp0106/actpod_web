import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:quick_share_app/utils/link_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class UserInfoWidget extends ConsumerWidget {

  UserInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserInfoDto? userInfo = ref.watch(otherUserInfoProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildUserAvatar(userInfo),
          SizedBox(width: 20.w,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 5.h,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 25.h,
                      width: 150.w,
                      child: AutoSizeText(
                        userInfo == null? AppLocalizations.of(context)!.anonymous : userInfo.nickname,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: ConfigColor.textColorDefault
                        ),
                      )
                    ),
                  ],
                ),
                SizedBox(height: 10.h,),
                Column(
                  children: [
                    Text(
                      ref.watch(otherStoryCountProvider).toString(),
                      style: TextStyle(
                        fontSize: 20.w,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      "Stories",
                      style: TextStyle(
                        fontSize: 16.w,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10.h,),
                SizedBox(
                  width: 200.w,
                  height: 72.h,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Linkify(
                      onOpen: LinkUtils.onOpenDescriptionLink,
                      options: const LinkifyOptions(humanize: false),
                      text: userInfo == null ? "" : userInfo.selfDescription,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: ConfigColor.textColorDefault,
                      ),
                    ),
                  ),
                )
              ],
            )
          )
        ]
      )
    );
  }

  Widget buildUserAvatar(UserInfoDto? userInfo) {
    return userInfo == null || userInfo.avatarUrl == ""?
    ClipOval(
      child: Image.asset(
        "assets/images/nullAvatar.png",
        width: 100.w,
        height: 100.w,
        fit: BoxFit.fill,
      )
    ):
    ClipOval(
        child: Image.network(
          userInfo.avatarUrl,
          width: 100.w,
          height: 100.w,
          fit: BoxFit.fitWidth,
        )
    );
  }
}