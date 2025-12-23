import 'package:actpod_web/api_manager/comment_dto/get_story_stat_res.dart';
import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/dto/comment_dto.dart';
import 'package:actpod_web/dto/interactive_content_dto.dart';
import 'package:actpod_web/dto/reply_dto.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlayContent {
  story,
  interactiveContent,
}

final storyStateProvider = StateProvider<GetStoryStatResItem?>((ref) => null);
final storyInfoProvider = StateProvider<GetOneStoryResItem?> ((ref) => null);
final playerSpeedTextProvider = StateProvider<String>((ref) => "1.0X");
final audioLengthProvider = StateProvider<Duration>((ref) => Duration.zero);
final audioPositionProvider = StateProvider<Duration>((ref) => Duration.zero);
final playerStatusProvider = StateProvider<String>((ref) => "preparing");// preparing, ready, playing, paused
final playContentProvider = StateProvider<PlayContent>((ref) => PlayContent.story);
final interactiveMessageInfoListProvider = StateProvider<List<InteractiveMessageInfoDto>?>((ref) => null);
final interactiveMessageInfoIndexProvider = StateProvider<int?>((ref) => null);

final isReplyModeProvider = StateProvider.autoDispose<bool>((ref) => false);
final replyListProvider = StateProvider<List<ReplyInfoDto>?>((ref) => null);
final commentListProvider = StateProvider<List<CommentInfoDto>?>((ref) => null);
final replyCommentProvider = StateProvider.autoDispose<CommentInfoDto?>((ref) => null);
final sendingProvider = StateProvider.autoDispose<bool>((ref) => false);
final instantCommentListProvider = StateProvider<List<InstantCommentInfoDto>?>((ref) => null);
final instantSendingProvider = StateProvider.autoDispose<bool>((ref) => false);

final selectedDonateAmountProvider = StateProvider.autoDispose<int>((ref) => 0);
final inputFocusProvider = StateProvider.autoDispose<bool>((ref) => false);