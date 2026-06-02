
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/home_page_feature/components/announcement_page.dart';

import '../../../dto/announcement_dto.dart';
import '../providers.dart';

class AnnouncementBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementList = ref.watch(announcementProvider);

    return Visibility(
      visible: announcementList != null,
      child: Center(
        child: const SizedBox.shrink()
      //   child: carousel_slider_controller.CarouselSlider(
      //     options: carousel_slider_controller.CarouselOptions(
      //       height: 100.h,
      //       viewportFraction: 1,
      //       autoPlay: true,
      //       autoPlayInterval: const Duration(seconds: 10),
      //       enableInfiniteScroll: announcementList != null && announcementList.length > 1? true : false
      //     ),
      //     items: announcementList?.map((announcement) {
      //       return Builder(
      //         builder: (BuildContext context) {
      //           return banner(context, ref, announcement);
      //         });
      //     }).toList()
      //   )
      )
    );
  }

  Widget banner(BuildContext context, WidgetRef ref, AnnouncementDto announcementDto) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return AnnouncementPage(announcementDto.announcementImageUrl);
        }));
      },
      child: ref.watch(announcementProvider) == null? const SizedBox.shrink() : Container(
        margin: EdgeInsets.only(top: 10.h),
        width: ScreenUtil().screenWidth,
        child: Image.network(
          announcementDto.bannerImageUrl,
          width: ScreenUtil().screenWidth,
          fit: BoxFit.fitWidth,
        ),
      )
    );
  }
}