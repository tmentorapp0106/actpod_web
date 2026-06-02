import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/user_info_feature/controllers/membership_controller.dart';
import 'package:quick_share_app/utils/string_utils.dart';

import '../../../main.dart';
import '../../../router.dart';
import '../providers.dart';
import 'option_bottom_sheet.dart';

class Membership extends ConsumerWidget {
  final MembershipController membershipController;

  Membership(this.membershipController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          add(),
          memberLevel(ref.watch(selfMembershipProvider)?.customerLevel),
          const Spacer(),
          more(context)
        ],
      )
    );
  }

  Widget add() {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        router.push("/record");
        actPodAudioHandler?.pause();
      },
      child: const SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          Icons.add_rounded,
          size: 28,
        ),
      ),
    );
  }

  Widget memberLevel(String? memberLevel) {
    if(memberLevel == null) {
      return const SizedBox.shrink();
    } else if(memberLevel == "Free") {
      return GestureDetector(
        onTap: () async {
          bool? purchase = await router.push("/subscribe");
          if(purchase != null && purchase) {
            membershipController.getMembership();
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: Color(0xfffff0ce)
          ),
          child: Center(
            child: Text(
              memberLevel
            ),
          )
        )
      );
    } else {
      return GestureDetector(
          onTap: () async {
            bool? purchase = await router.push("/subscribe");
            if(purchase != null && purchase) {
              membershipController.getMembership();
            }
          },
        child:Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            gradient: LinearGradient(
              colors: [Color(0xffFFBC1F), Color(0xffFF8142)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Center(
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 12.w,
                ),
                const SizedBox(width: 2,),
                Text(
                  memberLevel
                ),
              ]
            )
          )
        )
      );
    }
  }

  Widget more(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.w)
              )
          ),
          builder: (context) {
            return OptionBottomSheet();
          }
        );
      },
      child: Icon(
        Icons.more_horiz_rounded,
        size: 22.w,
      ),
    );
  }
}