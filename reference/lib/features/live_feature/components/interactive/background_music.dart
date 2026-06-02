import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/features/live_feature/providers.dart';

import '../../../../design_system/color.dart';

class BackgroundMusic extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {

      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: DesignColor.actpodPrimary50,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.music_note_rounded,
              size: 16,
              color: DesignColor.actpodPrimary500,
            ),
            const SizedBox(width: 2),
            Text(
              '背景音樂播放中',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: DesignColor.actpodPrimary500,
              ),
            ),
          ],
        ),
      )
    );
  }
}