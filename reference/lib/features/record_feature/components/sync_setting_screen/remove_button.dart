import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/providers.dart';

import '../../../../design_system/color.dart';
import '../../controllers/feed_controller.dart';
import '../../providers/providers.dart';

class RemoveButton extends ConsumerWidget {
  final FeedController feedController;

  RemoveButton({required this.feedController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: DesignColor.white,
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.w),
          minimumSize: const Size(0, 0),                 // allow smaller than default
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // shrink touch target
          visualDensity: VisualDensity.compact,           // less outer space
        ),
        onPressed: ref.watch(syncSettingProvider) == null
            ? null : () async {
            ref.watch(loadingProvider.notifier).state = true;
            await feedController.removeSyncSetting();
            ref.watch(loadingProvider.notifier).state = false;
            if(context.mounted) {
              Navigator.of(context).pop(true);
            }
        },
        child: const Text(
          '解除綁定',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      )
    );
  }
}