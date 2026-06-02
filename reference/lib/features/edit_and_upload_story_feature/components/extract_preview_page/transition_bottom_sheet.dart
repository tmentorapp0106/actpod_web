import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/dto/transition_dto.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/components/extract_preview_page/transition_name_dialog.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers/transition_providers.dart';

import '../../../../services/load_file_service.dart';
import '../../controllers/transition_controller.dart';

class TransitionBottomSheet {
  final TransitionController controller;

  TransitionBottomSheet(this.controller);

  Future<TransitionDto?> show(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 8.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: title(),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: upload(context, ref),
                        ),
                      ],
                    ),
                    loading(ref),
                    transitionList(ref),
                    SizedBox(height: 16.h,)
                  ],
                )
            );
          }
        );
      },
    );
  }

  static Widget loading(WidgetRef ref) {
    return Visibility(
      visible: ref.watch(transitionLoadingProvider),
      child: Center(
        child: SizedBox(
          height: 24.w,
          width: 24.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(DesignColor.primary50),
          ),
        )
      )
    );
  }

  Widget transitionList(WidgetRef ref) {
    List<TransitionDto>? transitionList = ref.watch(transitionListProvider);
    if (transitionList == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200.h, // Set height constraint for the list
      child: ListView.builder(
        itemCount: transitionList.length,
        itemBuilder: (context, index) {
          final transition = transitionList[index];
          Widget playerIcon;
          if(ref.watch(transitionPlayerIndexProvider) == index) {
            if(ref.watch(transitionPlayerStatusProvider) == PlayerStatus.playing) {
              playerIcon = IconButton(
                icon: Icon(Icons.pause_rounded),
                onPressed: () {
                  controller.stopTransition();
                },
              );
            } else if(ref.watch(transitionPlayerStatusProvider) == PlayerStatus.loading) {
              playerIcon = const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              );
            } else {
              playerIcon = IconButton(
                icon: Icon(Icons.play_arrow_rounded),
                onPressed: () {
                  controller.playTransition(transition.url, index);
                },
              );
            }
          } else {
            playerIcon = IconButton(
              icon: Icon(
                Icons.play_arrow_rounded,
              ),
              onPressed: () {
                controller.playTransition(transition.url, index);
              },
            );
          }
          return InkWell(
            onTap: () {
              Navigator.of(context).pop(transition);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  // Music name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transition.name,
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  playerIcon
                ],
              ),
            )
          );
        },
      ),
    );
  }

  Widget title() {
    return Text(
      "轉場音樂",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20.w,
      ),
    );
  }

  Widget upload(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        ref.watch(transitionLoadingProvider.notifier).state = true;
        File? file = await LoadFileService.loadAudioFile(
          progressFunction: (progress){}
        );
        ref.watch(transitionLoadingProvider.notifier).state = false;
        if(file != null && context.mounted) {
          TransitionNameDialog(controller, file)
              .show(context);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.w),
          color: DesignColor.primary50
        ),
        child: Text(
          "上傳",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.w
          ),
        )
      )
    );
  }
}
