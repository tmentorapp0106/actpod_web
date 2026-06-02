import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../design_system/color.dart';
import '../../../providers.dart';

class PlayerStatus extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerStatus = ref.watch(podcastPlayerStatusProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: getBoxColor(playerStatus),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  playerStatus == PodcastPlayerStatus.playing? Icons.play_arrow_rounded : Icons.pause_rounded,
                  size: 20,
                  color: playerStatus == PodcastPlayerStatus.playing? DesignColor.actpodPrimary500 : DesignColor.neutral600,
                ),
                const SizedBox(width: 2),
                Text(
                  getText(playerStatus),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: playerStatus == PodcastPlayerStatus.playing? DesignColor.actpodPrimary500 : DesignColor.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Color getBoxColor(PodcastPlayerStatus status) {
    if(status == PodcastPlayerStatus.playing) {
      return DesignColor.actpodPrimary50;
    } else {
      return DesignColor.neutral50;
    }
  }

  String getText(PodcastPlayerStatus status) {
    if(status == PodcastPlayerStatus.playing) {
      return "主持人播放中...";
    } else if(status == PodcastPlayerStatus.paused) {
      return "主持人暫停中...";
    } else {
      return "播放器準備中...";
    }
  }
}