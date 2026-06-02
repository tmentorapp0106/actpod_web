import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:quick_share_app/router.dart';
import 'package:quick_share_app/services/review_rating_service.dart';

import '../../../design_system/color.dart';

class PersonalSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 0.h, left: 16.w, right: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "我的紀錄",
                style: TextStyle(
                  fontSize: 20.w,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 4.h,),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      router.push("/collection");
                    },
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.w, horizontal: 4.w),
                        width: 164.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons/bookmark.svg",
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.fitWidth,
                                  color: DesignColor.neutral950
                                ),
                                const SizedBox(width: 2,),
                                Text(
                                  "收藏的頻道",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            )
                        )
                    )
                  )
                ],
              )
            ]
          )
        )
      ],
    );
  }
}