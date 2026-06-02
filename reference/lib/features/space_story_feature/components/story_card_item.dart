
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/components/story_card.dart';
import 'package:quick_share_app/controllers/preview_controller.dart';
import 'package:quick_share_app/dto/space_story_dto.dart';
import '../controllers/space_story_controller.dart';

class StoryCardItem extends ConsumerWidget {
  final int index;
  final List<SpaceStoryDto> spaceStoryInfoList;
  final SpaceStoryController spaceStoryController;
  final descriptionExpandedProvider =
  StateProvider.family<bool, int>((ref, index) => false);

  StoryCardItem(this.index, this.spaceStoryInfoList, this.spaceStoryController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StoryCard(index, spaceStoryDto: spaceStoryInfoList[index], previewPlayFunction: previewPlayerController.previewPlayFunction);
  }
}