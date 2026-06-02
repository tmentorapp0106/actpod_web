import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design.dart';
import '../../../dto/space_dto.dart';
import '../providers.dart';

class SpaceGridView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: 160 / 88, // Square items
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: ref.watch(spacesProvider).length,
        (context, index) {
          return spaceItem(context, ref.watch(spacesProvider)[index]);
        },// Change this based on your data
      ),
    );
  }

  Widget spaceItem(BuildContext context, SpaceInfoDto spaceInfo) {
    final radius = BorderRadius.circular(15.w);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.w, horizontal: 8.w),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: DesignSystem.shadow,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias, // clip ripple to rounded corners
        child: InkWell(
          borderRadius: radius,
          onTap: () => context.push("/spaceStory", extra: spaceInfo),
          child: Padding(
            padding: EdgeInsets.only(left: 8.w, right: 12.w),
            // This centers *and* makes the row shrink-wrap its width
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.network(
                    spaceInfo.imageUrl,
                    width: 48.w,
                    height: 48.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 8.w,),
                  Flexible(
                    child: Text(
                      spaceInfo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}