import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';

import '../provider.dart';

class ChannelState extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelInfo = ref.watch(channelInfoProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            channelInfo == null? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: DesignColor.actpodPrimary500,
              ),
            ) : Text(
              channelInfo.storyCount.toString(),
              style: const TextStyle(
                fontSize: 24
              ),
            ),
            const Text(
              "Stories",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}