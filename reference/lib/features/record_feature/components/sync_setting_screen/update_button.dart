import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/record_feature/controllers/feed_controller.dart';
import 'package:quick_share_app/features/record_feature/providers/providers.dart';

import '../../../../design_system/color.dart';

class UpdateButton extends ConsumerWidget {
  final FeedController feedController;

  UpdateButton({required this.feedController});

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
        final spaceId = ref.watch(spaceListProvider).firstWhere((space) => space.name == ref.watch(spaceSelectionProvider)).spaceId;
        final channelId = ref.watch(channelListProvider).firstWhere((channel) => channel.channelName == ref.watch(channelSelectionProvider)).channelId;
        await feedController.updateSyncSetting(channelId, spaceId);
      },
      child: const Text(
        '更新綁定',
        style: TextStyle(
            color: Colors.black
        ),
      ),
    );
  }
}