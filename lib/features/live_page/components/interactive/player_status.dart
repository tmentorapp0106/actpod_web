import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/live_page/providers/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerStatus extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingPodcastProvider);

    return GestureDetector(
      onTap: () {
        ref.watch(interactiveRoomModeProvider.notifier).state = InteractiveRoomMode.active;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isPlaying? DesignColor.actpodPrimary50 : DesignColor.neutral50,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPlaying? Icons.play_arrow_rounded : Icons.pause_rounded,
                    size: 16,
                    color: isPlaying? DesignColor.actpodPrimary500 : DesignColor.neutral600,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    isPlaying? "主持人播放中..." : "主持人暫停中...",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPlaying? DesignColor.actpodPrimary500 : DesignColor.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      )
    );
  }
}