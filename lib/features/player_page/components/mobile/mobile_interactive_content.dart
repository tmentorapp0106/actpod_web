import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MobileInteractiveContent extends ConsumerWidget {
  final PlayerController playerController;

  MobileInteractiveContent({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactiveList = ref.watch(interactiveMessageInfoListProvider);
    int interactiveIndex = ref.watch(interactiveMessageInfoIndexProvider)?? 0;

    return Visibility(
      visible: ref.watch(playContentProvider) == PlayContent.interactiveContent,
      child: Container(
        width: 340.w,
        height: 340.w,
        decoration: BoxDecoration(
          color: DesignColor.neutral50,
          borderRadius: BorderRadius.circular(8.w)
        ),
        child: Center(
          child: interactiveList == null? const CircularProgressIndicator(
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
                                  playerController.seekPosition(Duration(milliseconds: interactiveList[index].fromMilliSec));
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
                                  playerController.seekPosition(Duration(milliseconds: interactiveList[index].fromMilliSec));
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
      )
    );
  }
}