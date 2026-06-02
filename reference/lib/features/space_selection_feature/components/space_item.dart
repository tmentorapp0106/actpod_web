import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/features/space_story_feature/space_story_screen.dart';
import 'package:quick_share_app/services/page_router_service.dart';

import '../../../config/color.dart';
import '../../../dto/space_dto.dart';
import '../providers.dart';

class SpaceItem extends ConsumerWidget {
  final SpaceInfoDto spaceInfo;

  SpaceItem(this.spaceInfo);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(15.w),
      onTap: () {
        context.push("/spaceStory", extra: spaceInfo);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.w, horizontal: 8.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.w),
          color: Colors.white,
          boxShadow: DesignSystem.shadow,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.network(
                spaceInfo.imageUrl,
                width: 40.w,
                height: 40.w,
                fit: BoxFit.fitWidth,
              ),
              Text(
                spaceInfo.name,
                style: TextStyle(
                  fontSize: 20.w,
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          )
        )
      )
    );
  }
}