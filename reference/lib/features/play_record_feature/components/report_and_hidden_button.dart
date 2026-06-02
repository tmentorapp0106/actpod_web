import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/play_record_feature/providers.dart';
import 'package:quick_share_app/router.dart';
import 'package:quick_share_app/shared_prefs/hide_prefs.dart';

class ReportAndHiddenButton extends ConsumerWidget {
  final String storyId;

  ReportAndHiddenButton({required this.storyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () async {
            router.push("/report");
          },
          style: TextButton.styleFrom(
            fixedSize: const Size(84, 36),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1.w,
                color: Colors.red
              ),
              borderRadius: BorderRadius.circular(12), // Set the border radius here
            ),
          ),
          child: Text(
            "檢舉",
            style: TextStyle(
              color: Colors.red,
              fontSize: 16
            ),
          ),
        ),

        const SizedBox(width: 12,),

        TextButton(
          onPressed: () async {
            if(!ref.watch(hiddenProvider)) {
              HidePrefs.addId(storyId);
              ref.watch(hiddenProvider.notifier).state = true;
            } else {
              HidePrefs.removeId(storyId);
              ref.watch(hiddenProvider.notifier).state = false;
            }
          },
          style: TextButton.styleFrom(
            fixedSize: ref.watch(hiddenProvider)? const Size(120, 36) : const Size(84, 36),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1.w,
                color: Colors.grey
              ),
              borderRadius: BorderRadius.circular(12), // Set the border radius here
            ),
          ),
          child: Text(
            ref.watch(hiddenProvider)?"取消隱藏" : "隱藏",
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 16
            ),
          ),
        ),
      ],
    );
  }
}