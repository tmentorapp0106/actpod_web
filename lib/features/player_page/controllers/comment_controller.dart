import 'package:actpod_web/api_manager/comment_dto/create_comment_res.dart';
import 'package:actpod_web/api_manager/comment_dto/create_reply_res.dart';
import 'package:actpod_web/api_manager/comment_dto/delete_comment_res.dart';
import 'package:actpod_web/api_manager/comment_dto/get_comment_list_res.dart';
import 'package:actpod_web/api_manager/comment_dto/get_reply_list_res.dart';
import 'package:actpod_web/api_manager/comment_system_api_manager.dart';
import 'package:actpod_web/dto/comment_dto.dart';
import 'package:actpod_web/dto/reply_dto.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/toast_service.dart';

class CommentController {
  WidgetRef ref;

  CommentController({required this.ref});

  Future<void> getComments(String storyId) async {
    GetCommentListRes response = await commentApiManager.getCommentList(storyId);
    if(response.code != "0000") {
      return;
    }
    ref.watch(commentListProvider.notifier).state = response.commentInfo == null? [] : response.commentInfo!.commentList;
  }

  Future<void> getInstantComments(String storyId) async {
    GetInstantCommentListRes response = await commentApiManager.getInstantCommentList(storyId);
    if(response.code != "0000") {
      return;
    }
    ref.watch(instantCommentListProvider.notifier).state = response.commentInfo?.commentList;
  }

  Future<void> createComment(String storyId, String content, int sendTiming, int donateAmount) async {
    CreateCommentRes response;
    if(donateAmount != 0) {
      response = await commentApiManager.createSuperComment(storyId, content, sendTiming, donateAmount);
    } else {
      response = await commentApiManager.createComment(storyId, content, sendTiming);
    }
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    UserInfoDto? userInfo = UserPrefs.getUserInfo();
    CommentInfoDto newCommentInfo = CommentInfoDto(
      response.commentId,
      userInfo!.userId,
      content,
      0,
      sendTiming,
      DateTime.now(),
      donateAmount == 0? "Regular" : "Super",
      "",
      userInfo.avatarUrl,
      userInfo.username,
      userInfo.nickname,
      userInfo.gender,
      userInfo.email,
      userInfo.selfDescription,
      donateAmount
    );
    final currentList = ref.read(commentListProvider) ?? [];

    // Set the new list with the new comment at the top (or bottom, depending on UX)
    ref.watch(commentListProvider.notifier).state = [
      newCommentInfo,
      ...currentList,
    ];
    ref.watch(storyStateProvider.notifier).state = ref.watch(storyStateProvider)!.copyWith(commentCount: ref.watch(storyStateProvider)!.commentCount + 1);
    ToastService.showSuccessToast("傳送成功");
  }

  Future<void> getReply(String commentId) async {
    GetReplyByCommentRes replyListRes = await commentApiManager.getReplyListByComment(commentId);
    if(replyListRes.code != "0000") {
      return;
    }
    ref.watch(replyListProvider.notifier).state = replyListRes.replyList?? [];
  }

  Future<void> createReply(String storyId, String storyOwnerUserId, String commentId, String content) async {
    final userInfo = UserPrefs.getUserInfo();
    String replyType = userInfo!.userId == storyOwnerUserId? "owner" : "listener";
    CreateReplyRes response = await commentApiManager.createReply(storyId, commentId, userInfo.userId, replyType, content);
    if(response.code != "0000") {
      ToastService.showNoticeToast("傳送失敗");
      return;
    }

    ReplyInfoDto newReplyInfo = ReplyInfoDto(
        "",
        commentId,
        userInfo.userId,
        replyType,
        content,
        DateTime.now(),
        userInfo.avatarUrl,
        userInfo.username,
        userInfo.nickname,
        userInfo.gender,
        userInfo.email,
        userInfo.selfDescription
    );
    final currentList = ref.read(replyListProvider) ?? [];

    // Set the new list with the new comment at the top (or bottom, depending on UX)
    ref.watch(replyListProvider.notifier).state = [
      newReplyInfo,
      ...currentList,
    ];
    ref.watch(storyStateProvider.notifier).state = ref.watch(storyStateProvider)!.copyWith(commentCount: ref.watch(storyStateProvider)!.commentCount + 1);
    ToastService.showSuccessToast("傳送成功");
  }

  Future<void> deleteComment(String commentId) async {
    DeleteCommentRes deleteCommentRes = await commentApiManager.deleteComment(commentId);
    if(deleteCommentRes.code != "0000") {
      ToastService.showNoticeToast("留言刪除失敗");
      return;
    }

    List<CommentInfoDto>? commentList = ref.watch(commentListProvider);
    commentList?.removeWhere((comment) => comment.commentId == commentId);
    ref.watch(commentListProvider.notifier).state = [...?commentList];
    ref.watch(storyStateProvider.notifier).state = ref.watch(storyStateProvider)!.copyWith(commentCount: ref.watch(storyStateProvider)!.commentCount - 1);
  }

  Future<void> createInstantComment(String storyId, String content, int sendSecond, int podcoins) async {
    CreateCommentRes response = await commentApiManager.createInstantComment(storyId, content, sendSecond, podcoins);
    if(response.code != "0000") {
      ToastService.showNoticeToast("傳送失敗");
      return;
    }

    UserInfoDto userInfo = UserPrefs.getUserInfo()!;
    InstantCommentInfoDto newInstantCommentInfo = InstantCommentInfoDto(
        response.commentId,
        userInfo.userId,
        content,
        0,
        sendSecond,
        0,
        userInfo.avatarUrl,
        userInfo.username,
        userInfo.nickname,
        userInfo.gender,
        userInfo.email,
        userInfo.selfDescription
    );

    List<InstantCommentInfoDto> instantCommentList = ref.watch(instantCommentListProvider)?? [];
    ref.watch(instantCommentListProvider.notifier).state = [
      newInstantCommentInfo,
      ...instantCommentList,
    ];
    ToastService.showSuccessToast("傳送成功");
  }
}