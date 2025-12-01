import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/features/personal_page/providers.dart';
import 'package:actpod_web/utils/link_utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserInfoWidget extends ConsumerWidget {

  UserInfoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserInfoDto? userInfo = ref.watch(userInfoProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Avatar(userInfo?.userId, userInfo?.avatarUrl, 100.w),
          SizedBox(width: 20.w,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 4.h,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      userInfo == null? "未知的使用者" : userInfo.nickname,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16.w,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    Text(
                      ref.watch(storyCountProvider).toString(),
                      style: TextStyle(
                        fontSize: 16.w,
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
                SizedBox(height: 6.h,),
                SizedBox(
                  width: 200.w,
                  height: 80.h,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Linkify(
                      onOpen: LinkUtils.onOpenDescriptionLink,
                      options: const LinkifyOptions(humanize: false),
                      text: userInfo == null ? "" : userInfo.selfDescription,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black,
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
}