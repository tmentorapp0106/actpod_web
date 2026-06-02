import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import '../../../l10n/app_localizations.dart';

import '../controllers/coins_and_cash_controller.dart';
import 'coins_and_cash.dart';

class UserInfoWidget extends ConsumerWidget {
  CoinsAndCashController _coinsAndCashController;

  UserInfoWidget(this._coinsAndCashController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserInfoDto? userInfo = ref.watch(selfUserInfoProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              buildUserAvatar(userInfo),
              SizedBox(height: 4.h,),
              CoinsAndCash(),
            ]
          ),
          SizedBox(width: 8.w,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 4.h,),
                SizedBox(
                  height: 32.h,
                  width: 168.w,
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
                SizedBox(height: 10.h,),
                Column(
                  children: [
                    Text(
                      ref.watch(selfStoryCountProvider).toString(),
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