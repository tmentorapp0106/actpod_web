import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/apiManagers/comment_api_dto/get_stickers_res.dart';
import 'package:quick_share_app/dto/comment_dto.dart';
import 'package:quick_share_app/dto/reply_dto.dart';

import '../../apiManagers/comment_api_dto/get_story_stat_res.dart';
import '../../dto/interactive_content_dto.dart';

final isForegroundProvider = StateProvider.autoDispose<bool>((ref) => true);
final voiceMessageStatusProvider = StateProvider.autoDispose<bool>((ref) => false);

final likeStatusProvider = StateProvider.autoDispose<bool>((ref) => false);
final storyStateProvider = StateProvider<GetStoryStatResItem?>((ref) => null);

final playerSpeedTextProvider = StateProvider<String>((ref) => "1.0X");

final showShareLinkProvider = StateProvider.autoDispose<bool>((ref) => true);

// comment providers
final sendingProvider = StateProvider.autoDispose<bool>((ref) => false);
final instantSendingProvider = StateProvider.autoDispose<bool>((ref) => false);
final isReplyModeProvider = StateProvider.autoDispose<bool>((ref) => false);
final replyListProvider = StateProvider<List<ReplyInfoDto>?>((ref) => null);
final commentListProvider = StateProvider<List<CommentInfoDto>?>((ref) => null);
final instantCommentListProvider = StateProvider<List<InstantCommentInfoDto>?>((ref) => null);
final replyCommentProvider = StateProvider.autoDispose<CommentInfoDto?>((ref) => null);
final instantCommentVisibilityProvider = StateProvider<bool>((ref) => true);
final interactiveMessageInfoListProvider = StateProvider<List<InteractiveMessageInfoDto>?>((ref) => null);
final interactiveMessageInfoIndexProvider = StateProvider<int?>((ref) => null);
final isShowingInteractiveContentProvider = StateProvider<bool>((ref) => false);

final selectedDonateAmountProvider = StateProvider.autoDispose<int>((ref) => 0);
final inputFocusProvider = StateProvider.autoDispose<bool>((ref) => false);
final instantInputFocusProvider = StateProvider.autoDispose<bool>((ref) => false);

class InstantCommentPosition {
  double from;
  double to;

  InstantCommentPosition({required this.from, required this.to});
}
final instantCommentWaitingQueue = Queue<InstantCommentInfoDto>();
final instantCommentPositionQueue = Queue<InstantCommentPosition>();
final instantCommentWidgets = StateProvider<List<Widget>>((ref) => []);
final List<InstantCommentInfoDto> instantCommentSendList = []; // send comment will add to queue when time goes by or when seeking.

enum PremiumStatus {
  unpaid,
  paid
}
final premiumStatusProvider = StateProvider.autoDispose<PremiumStatus?>((ref) => null);

final hiddenProvider = StateProvider.autoDispose<bool>((ref) => false);

enum CollectStatus {
  notLogin,
  collected,
  notCollected
}
final isCollectedProvider = StateProvider<CollectStatus?>((ref) => null);