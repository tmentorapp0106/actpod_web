import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_share_app/controllers/preview_controller.dart';
import 'package:quick_share_app/dto/space_dto.dart';
import 'package:quick_share_app/features/home_page_feature/providers.dart';

import '../../../providers.dart';
import '../../../router.dart';

class SpaceSection extends ConsumerWidget {

  SpaceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<SpaceInfoDto> spaces = ref.watch(spaceListProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(ref),
        Expanded(
          child: wrapSpaces(ref, spaces)
        )
      ],
    );
  }

  Widget wrapSpaces(WidgetRef ref, List<SpaceInfoDto> spaces) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1,
          crossAxisCount: 1, // Number of columns in the grid
          crossAxisSpacing: 0.w, // Spacing between columns
          mainAxisSpacing: 4.w, // Spacing between rows
        ),
        itemCount: spaces.length,
        itemBuilder: (context, index) {
          return spaceWidget(context, ref, spaces[index]);
        }
      )
    );
  }

  Widget spaceWidget(BuildContext context, WidgetRef ref, SpaceInfoDto space) {
    return GestureDetector(
      onTap: () async {
        previewPlayerController.stop(ref, force: true);
        await context.push("/spaceStory", extra: space);
        previewPlayerController.reset(ref, PreviewPage.home);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.w, horizontal: 4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.w),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF200066).withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 5.h,),
              SvgPicture.network(
                space.imageUrl,
                width: 32.w,
                fit: BoxFit.fitWidth,
              ),
              Text(
                space.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.w
                ),
              ),
            ],
          )
        )
      )
    );
  }

  Widget _title(WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(top: 0.h, left: 16.w, right: 16.w),
      child: Column(
        children: [
          Text(
            "空間列表",
            style: TextStyle(
              fontSize: 20.w,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 4.h,)
        ]
      )
    );
  }
}