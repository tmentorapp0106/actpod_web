import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/avatar.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../design_system/color.dart';
import '../providers.dart';

class InteractiveContentIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactiveList = ref.watch(interactiveMessageInfoListProvider);
    int interactiveIndex = ref.watch(interactiveMessageInfoIndexProvider)?? 0;

    return Container(
      width: 342.w,
      height: 342.w,
      decoration: BoxDecoration(
        color: DesignColor.neutral50,
        borderRadius: BorderRadius.circular(8.w)
      ),
      child: Center(
        child: interactiveList == null? CircularProgressIndicator(
            color: DesignColor.primary50
        ) : Stack(
          children: [
            // Big avatar in the center
            Positioned(
              top: 0,
              bottom: 0,
              left: 54.w,
              child: Container(
                width: 120.w,  // 32 + border*2
                height: 120.w, // keep it square
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DesignColor.primary50,
                    width: 4.w,               // actual visible border
                  ),
                ),
                child: Center(
                  child: Avatar(null, interactiveList[interactiveIndex].avatarUrl, 114.w)
                )
              )
            ),

            // Small avatars list at bottom-right
            Positioned(
              top: 0,
              bottom: 0,
              right: 44.w,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 340.w, // 👈 max height for the list
                    minWidth: 32.w,
                    maxWidth: 32.w
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: interactiveList.length,
                    itemBuilder: (context, index) {
                      if(interactiveIndex == index) {
                        return  Container(
                          width: 36.w,  // 32 + border*2
                          height: 36.w, // keep it square
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: DesignColor.primary50,
                              width: 2,               // actual visible border
                            ),
                          ),
                          child: Center(
                            child: Avatar(
                              null,
                              interactiveList[index].avatarUrl,
                              32.w,
                              tapFunction: () {
                                actPodAudioHandler?.seek(Duration(milliseconds: interactiveList[index].fromMilliSec));
                              },
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          width: 32.w,  // 32 + border*2
                          height: 32.w, // keep it square
                          padding: EdgeInsets.all(2.w), // thickness of border area
                          child: Center(
                            child: Avatar(
                              null,
                              interactiveList[index].avatarUrl,
                              32.w,
                              tapFunction: () {
                                actPodAudioHandler?.seek(Duration(milliseconds: interactiveList[index].fromMilliSec));
                              },// avatar stays same size
                            ),
                          ),
                        );
                      }
                    },
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 4.h),
                  ),
                ),
              )
            ),
          ],
        ),
      )
    );
  }
}