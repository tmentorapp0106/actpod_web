import 'package:actpod_web/api_manager/comment_dto/create_comment_res.dart';
import 'package:actpod_web/api_manager/comment_dto/create_reply_res.dart';
import 'package:actpod_web/api_manager/comment_dto/delete_comment_res.dart';
import 'package:actpod_web/api_manager/comment_dto/get_comment_list_res.dart';
import 'package:actpod_web/api_manager/comment_dto/get_reply_list_res.dart';
import 'package:actpod_web/api_manager/comment_system_api_manager.dart';
import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/podcoin.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/dto/comment_dto.dart';
import 'package:actpod_web/dto/reply_dto.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_instant_comment.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/utils/screen_utils.dart';
import 'package:actpod_web/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../services/toast_service.dart';

class CommentController {
  WidgetRef ref;
  final instantCommentHeight = 340.w;
  int lastInstantCommentSecond = 0;
  bool isProcessingInstantComment = false;

  CommentController({required this.ref});

  void clearInstantQueue() {
    ref.watch(instantCommentWidgets.notifier).state = List<Widget>.generate((instantCommentHeight * 2 / 10).toInt() + 2, (_) => const SizedBox.shrink());
    instantCommentPositionQueue.clear();
    instantCommentSendList.clear();
    instantCommentWaitingQueue.clear();
  }

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

  Future<void> fireInstantComment(BuildContext context) async {
    if(isProcessingInstantComment || ref.watch(playContentProvider) == PlayContent.interactiveContent) {
      return;
    }
    isProcessingInstantComment = true;
    // scan all widgets and get head and tail positions
    double head, tail;
    if(instantCommentPositionQueue.isEmpty) {
      head = 0;
      tail = 0;
    } else {
      head = instantCommentPositionQueue.first.from;
      tail = instantCommentPositionQueue.last.to;
    }
    List<Widget> comments = ref.read(instantCommentWidgets);

    if(ref.watch(playerStatusProvider) != PlayerStatus.playing) {
      while(instantCommentWaitingQueue.isNotEmpty) {
        InstantCommentInfoDto commentInfo = instantCommentWaitingQueue.first;
        InstantCommentPosition position = _getInstantPosition(head, tail, _getInstantWidgetHeight(context, commentInfo.content, commentInfo.podcoins));
        if(position.from < 0) {
          ref.watch(instantCommentWidgets.notifier).state = [...comments];
          isProcessingInstantComment = false;
          return;
        }

        instantCommentWaitingQueue.removeFirst();
        instantCommentPositionQueue.add(position);
        tail = position.to;
        comments[(position.from / 10).toInt()] = MobileInstantComment(
            commentKey: commentInfo.commentId,
            commentController: this,
            commentInfo: commentInfo,
            index: (position.from / 10).toInt(),
            top: position.from % instantCommentHeight + 12.h,
            left: position.from >= instantCommentHeight? null : 16.w,
            right: position.from >= instantCommentHeight? 16.w : null
        );
      }
      ref.watch(instantCommentWidgets.notifier).state = [...comments];
      isProcessingInstantComment = false;
      return;
    }

    int playingSecond = ref.watch(audioPositionProvider).inSeconds;
    if(lastInstantCommentSecond == playingSecond) {
      ref.watch(instantCommentWidgets.notifier).state = [...comments];
      isProcessingInstantComment = false;
      return;
    }
    lastInstantCommentSecond = playingSecond;

    // fire comment in waiting queue first
    while(instantCommentWaitingQueue.isNotEmpty) {
      InstantCommentInfoDto commentInfo = instantCommentWaitingQueue.first;
      InstantCommentPosition position = _getInstantPosition(head, tail, _getInstantWidgetHeight(context, commentInfo.content, commentInfo.podcoins));
      if(position.from < 0) {
        List<InstantCommentInfoDto>? instantComments = ref.read(instantCommentListProvider)?.where((comment) {
          return comment.sendSecond == playingSecond;
        }).toList();
        for(int i = 0; i < instantComments!.length; i++) {
          instantCommentWaitingQueue.add(instantComments[i]);
        }
        ref.watch(instantCommentWidgets.notifier).state = [...comments];
        isProcessingInstantComment = false;
        return;
      }

      instantCommentWaitingQueue.removeFirst();
      instantCommentPositionQueue.add(position);
      tail = position.to;
      comments[(position.from / 10).toInt()] = MobileInstantComment(
          commentKey: commentInfo.commentId,
          commentController: this,
          commentInfo: commentInfo,
          index: (position.from / 10).toInt(),
          top: position.from % instantCommentHeight + 12.h,
          left: position.from >= instantCommentHeight? null : 16.w,
          right: position.from >= instantCommentHeight? 16.w : null
      );
    }

    // add past comment in send queue
    List<InstantCommentInfoDto> pastComments = instantCommentSendList.where((comment) => comment.sendSecond < playingSecond).toList();
    instantCommentSendList.removeWhere((comment) => comment.sendSecond < playingSecond);
    if(pastComments.isNotEmpty) {
      List<InstantCommentInfoDto>? commentList = ref.watch(instantCommentListProvider);
      commentList?.addAll(pastComments);
      ref.watch(instantCommentListProvider.notifier).state = [...?commentList];
    }

    List<InstantCommentInfoDto>? instantComments = ref.read(instantCommentListProvider)?.where((comment) {
      return comment.sendSecond == playingSecond;
    }).toList();
    if(instantComments == null) {
      ref.watch(instantCommentWidgets.notifier).state = [...comments];
      isProcessingInstantComment = false;
      return;
    }

    for(int i = 0; i < instantComments.length; i++) {
      final widgetHeight = _getInstantWidgetHeight(context, instantComments[i].content, instantComments[i].podcoins);
      final position = _getInstantPosition(head, tail, widgetHeight);
      if(position.from < 0) {
        for(int j = i; j < instantComments.length; j++) {
          instantCommentWaitingQueue.add(instantComments[j]);
        }
        ref.watch(instantCommentWidgets.notifier).state = [...comments];
        isProcessingInstantComment = false;
        return;
      }

      instantCommentPositionQueue.add(position);
      tail = position.to;
      comments[(position.from / 10).toInt()] = MobileInstantComment(
          commentController: this,
          commentKey: instantComments[i].commentId,
          commentInfo: instantComments[i],
          index: (position.from / 10).toInt(),
          top: position.from % instantCommentHeight + 12.h,
          left: position.from >= instantCommentHeight? null : 16.w,
          right: position.from >= instantCommentHeight? 16.w : null
      );
    }
    ref.watch(instantCommentWidgets.notifier).state = [...comments];
    isProcessingInstantComment = false;
  }

  InstantCommentPosition _getInstantPosition(double head, double tail, double widgetHeight) {
    double from, newTail;
    if(tail < instantCommentHeight) { // tail is in first row
      from = tail + widgetHeight > instantCommentHeight? instantCommentHeight : tail;
      newTail = tail + widgetHeight > instantCommentHeight? instantCommentHeight + widgetHeight : tail + widgetHeight;
      if(head > tail) { // tail 快追上 head
        if(newTail > head) { // tail 超過 head
          return InstantCommentPosition(from: -1, to: 0); // push to waiting queue
        } else {
          return InstantCommentPosition(from: from, to: newTail);
        }
      } else {
        return InstantCommentPosition(from: from, to: newTail);
      }
    } else { // tail is in second row
      from = tail + widgetHeight > instantCommentHeight * 2? 0 : tail;
      newTail = tail + widgetHeight > instantCommentHeight * 2? 0 + widgetHeight : tail + widgetHeight;
      if(head > tail) {
        if(newTail > head) {
          return InstantCommentPosition(from: -1, to: 0);
        } else {
          return InstantCommentPosition(from: from, to: newTail);
        }
      } else {
        if(newTail > instantCommentHeight) { // doesn't change to first row
          return InstantCommentPosition(from: from, to: newTail);
        } else {
          if(newTail > head) {
            return InstantCommentPosition(from: -1, to: 0);
          } else {
            return InstantCommentPosition(from: from, to: newTail);
          }
        }
      }
    }
  }

  // measure instant widget's size
  double _getInstantWidgetHeight(BuildContext context, String content, int podcoins) {
    final bubbleWidth = 150.w;          // same as your container width
    final inner = Directionality(textDirection: TextDirection.ltr,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        width: bubbleWidth,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.w)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(null, null, 16.w),
                SizedBox(width: 8.w),
                Text(
                  StringUtils.shorten("fake user nickname", 15),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.w),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Visibility(
              visible: podcoins != 0,
              child: Container(
                margin: EdgeInsets.only(bottom: 2.h),
                padding: EdgeInsets.symmetric(
                    horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(10.w),
                  color: DesignColor.secondary500,
                ),
                child: Row(
                  children: [
                    PodCoin(size: 12.w),
                    const SizedBox(width: 2),
                    Text(
                      podcoins.toString(),
                      style: const TextStyle(
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              content,
              softWrap: true,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14.w), // use size different to measure padding between text lines
            ),
          ],
        ),
      )
    );

    final boxSize = ScreenUtils.measureWidget(inner);
    return boxSize.height;
  }
}