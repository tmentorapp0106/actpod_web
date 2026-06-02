import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/record_feature/controllers/feed_controller.dart';

import '../../../../design_system/color.dart';
import '../../providers/providers.dart';

class InstantSyncButton extends ConsumerWidget {
  final FeedController feedController;

  InstantSyncButton({required this.feedController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: DesignColor.white,
        backgroundColor: DesignColor.primary50,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.w),
        minimumSize: const Size(0, 0),                 // allow smaller than default
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // shrink touch target
        visualDensity: VisualDensity.compact,           // less outer space
      ),
      onPressed: ref.watch(syncSettingProvider) == null
          ? null
          : () async {
        feedController.manualSync();
      },
      child: const Text(
        '立即同步',
        style: TextStyle(
            color: Colors.black
        ),
      ),
    );
  }
}