import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/color.dart';
import '../../../dto/user_info_dto.dart';
import '../../../utils/link_utils.dart';
import '../providers.dart';

class Description extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserInfoDto? userInfo = ref.watch(selfUserInfoProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 4.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 80.h,
          minWidth: double.infinity,
          maxWidth: double.infinity
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Linkify(
            onOpen: LinkUtils.onOpenDescriptionLink,
            options: const LinkifyOptions(humanize: false),
            textAlign: TextAlign.start,
            text: userInfo == null ? "" : userInfo.selfDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: ConfigColor.textColorDefault,
            ),
          ),
        ),
      )
    );
  }
}