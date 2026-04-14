import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/live_page/providers/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryName extends ConsumerWidget {
  final bool isHost;

  StoryName({required this.isHost});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GetOneStoryResItem? storyInfo = ref.watch(storyInfoProvider);

    if (storyInfo == null) {
      return const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: DesignColor.actpodPrimary500,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            storyInfo.storyName,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              height: 1.2,
            ),
          )
        ),
        // isHost? ResumePlayButton() : const SizedBox.shrink()
      ]
    );
  }
}