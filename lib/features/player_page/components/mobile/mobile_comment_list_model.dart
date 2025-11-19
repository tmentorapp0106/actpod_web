import 'dart:io';

import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/podcoin.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/dto/comment_dto.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_delete_comment_dialog.dart';
import 'package:actpod_web/features/player_page/controllers/comment_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/utils/cookie_utils.dart';
import 'package:actpod_web/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommentBottomModel {
  final podcoinOptions = [0, 10, 20, 30, 50, 70, 100, 200, 500, 1000, 2000, 5000];
  final CommentController commentController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode focusNode;
  
  
  CommentBottomModel({
    required this.commentController,
    required this.focusNode,
  });

  Future<void> show(
      BuildContext context,
      String storyId,
      String? storyOwnerUserId
  ) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Consumer(
              builder: (context, ref, _) {
                return GestureDetector(
                  onTap: () {
                    focusNode.unfocus();
                  },
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            if (ref.watch(isReplyModeProvider))
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () {
                                  ref.watch(isReplyModeProvider.notifier).state = false;
                                  ref.watch(replyListProvider.notifier).state = null;
                                  ref.watch(replyCommentProvider.notifier).state = null;
                                },
                              ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  ref.watch(isReplyModeProvider) ? "留言回覆" : "留言",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.w,
                                  ),
                                ),
                              ),
                            ),
                            ref.watch(isReplyModeProvider) ? SizedBox(width: 48) : const SizedBox.shrink(), // Space for symmetry if back icon is shown
                          ],
                        ),
                      ),

                      // Comment or Reply List
                      Expanded(
                        child:AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(1.0, 0.0), // From right
                              end: Offset.zero,
                            ).animate(animation);
                            return SlideTransition(position: offsetAnimation, child: child);
                          },
                          child: ref.watch(isReplyModeProvider)
                            ? _buildReplyList(scrollController, ref, key: ValueKey("reply"))
                            : _buildCommentList(scrollController, ref, key: ValueKey("comment")),
                        ),
                      ),

                      // Input Bar
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom + 32.h,
                          left: 16,
                          right: 16,
                          top: 8,
                        ),
                        child: Column(
                          children: [
                            Visibility(
                              visible: ref.watch(inputFocusProvider),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "發表留言並贊助: ${ref.watch(selectedDonateAmountProvider).toString()}",
                                        style: TextStyle(
                                          fontSize: 14.w
                                        ),
                                      ),
                                      SizedBox(width: 4.w,),
                                      PodCoin(size: 12.w),
                                      const Spacer(),
                                      // Text(
                                      //   "剩餘 Podcoin: ${ref.watch(userPodCoinsProvider)}"
                                      // ),
                                      SizedBox(width: 4.w,),
                                      PodCoin(size: 12.w),
                                    ],
                                  ),
                                  SizedBox(height: 12.h,),
                                  SizedBox(
                                    height: 28.h,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: podcoinOptions.length,
                                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                                      itemBuilder: (context, i) {
                                        final amount = podcoinOptions[i];
                                        final isSelected = ref.watch(selectedDonateAmountProvider) == amount;
                                        return GestureDetector(
                                            onTap: () {
                                              ref.watch(selectedDonateAmountProvider.notifier).state = amount;
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30),
                                                  color: isSelected? DesignColor.primary100 : Colors.white,
                                                  border: Border.all(
                                                      color: DesignColor.neutral300,
                                                      width: 1
                                                  )
                                              ),
                                              child: Row(
                                                children: [
                                                  PodCoin(size: 20.w),
                                                  SizedBox(width: 8.w,),
                                                  Text(
                                                    amount.toString(),
                                                    style: TextStyle(
                                                        fontSize: 12.w
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 12.h,),  
                                ],
                              )
                            ),
                            Row(
                              children: [
                                Avatar(null, UserPrefs.getUserInfo()?.avatarUrl, 24.w),
                                SizedBox(width: 8.w,),
                                Expanded(
                                  child: TextField(
                                    focusNode: focusNode,
                                    controller: _textController,
                                    decoration: InputDecoration(
                                      hintText: ref.watch(isReplyModeProvider) ? "回覆留言..." : "發表留言...",
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    if(_textController.text == "") {
                                      return;
                                    }
                                    if(CookieUtils.getCookie("userToken") == null || CookieUtils.getCookie("userToken") == "") {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return LoginScreen();
                                        }
                                      );
                                      return;
                                    }
                                    ref.watch(sendingProvider.notifier).state = true;
                                    if(ref.watch(isReplyModeProvider)) {
                                      await commentController.createReply(storyId, storyOwnerUserId!, ref.watch(replyCommentProvider)!.commentId, _textController.text);
                                    } else {
                                      await commentController.createComment(storyId, _textController.text, 0, ref.watch(selectedDonateAmountProvider));
                                    }
                                    ref.watch(sendingProvider.notifier).state = false;
                                    _textController.text = "";
                                  },
                                  child: ref.watch(sendingProvider)? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: DesignColor.primary50,
                                    ),
                                  ) :Icon(
                                    Icons.send,
                                    size: 24,
                                    color: DesignColor.primary50,
                                  )
                                ),
                              ],
                            )
                          ]
                        ),
                      ),
                    ],
                  )
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCommentList(ScrollController scrollController, WidgetRef ref, {required Key key}) {
    List<CommentInfoDto>? comments = ref.watch(commentListProvider);
    String? userId = UserPrefs.getUserInfo()?.userId;
    if(comments == null) {
      return const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
              color: DesignColor.primary50,
              strokeWidth: 4
          ),
        ),
      );
    }
    return ListView.builder(
      key: key,
      controller: scrollController,
      itemCount: ref.watch(commentListProvider)!.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Avatar(comment.userId, comment.avatarUrl, 12.w),
                  SizedBox(width: 8.w),
                  Text(StringUtils.shorten(comment.nickname, 15), style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 8.w),
                  Visibility(
                    visible: comment.podcoins != 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.w),
                        color: DesignColor.secondary500
                      ),
                      child: Row(
                        children: [
                          PodCoin(size: 12.w),
                          SizedBox(width: 2,),
                          Text(
                            comment.podcoins.toString(),
                            style: TextStyle(
                              color: Colors.white
                            ),
                          )
                        ],
                      )
                    )
                  )
                ],
              ),
              SizedBox(height: 6),
              Text(
                comment.content
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.watch(isReplyModeProvider.notifier).state = true;
                      ref.watch(replyCommentProvider.notifier).state = comment;
                      commentController.getReply(comment.commentId);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.comment_outlined, size: 16),
                        SizedBox(width: 4),
                        Text(
                          comment.replyCount == 0? "回覆" : "${comment.replyCount} 則回覆",
                          style: TextStyle(
                            fontSize: 12.w
                          ),
                        ),
                        const SizedBox(width: 8,),
                        Visibility(
                          visible: userId != null && userId == comment.userId,
                          child: GestureDetector(
                            onTap: () async {
                              bool? delete = await DeleteCommentDialog(comment.commentId, context).show();
                              if(delete != null && delete) {
                                commentController.deleteComment(comment.commentId);
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red,
                                  size: 16.w,
                                ),
                                Text(
                                  "刪除",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.w
                                  ),
                                )
                              ]
                            )
                          )
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReplyList(ScrollController scrollController, WidgetRef ref, {required Key key}) {
    final replyList = ref.watch(replyListProvider);
    final comment = ref.watch(replyCommentProvider);
    return ListView.builder(
      key: key,
      controller: scrollController,
      itemCount: replyList == null? 1 : replyList.length + 1, // 1 comment + 100 replies
      itemBuilder: (context, index) {
        if (index == 0) {
          // The original comment being replied to
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Avatar(comment!.userId, comment.avatarUrl, 14.w),
                    SizedBox(width: 8),
                    Text(
                      comment.nickname,
                      maxLines: 1,
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    SizedBox(width: 8.w),
                    Visibility(
                        visible: comment.podcoins != 0,
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.w),
                                color: DesignColor.secondary500
                            ),
                            child: Row(
                              children: [
                                PodCoin(size: 12.w),
                                SizedBox(width: 2,),
                                Text(
                                  comment.podcoins.toString(),
                                  style: TextStyle(
                                      color: Colors.white
                                  ),
                                )
                              ],
                            )
                        )
                    )
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  comment.content,
                  softWrap: true,
                ),
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 12),
                Visibility(
                  visible: replyList == null,
                  child: Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        color: DesignColor.primary50,
                        strokeWidth: 4
                      ),
                    )
                  ),
                )
              ],
            ),
          );
        } else {
          final reply = replyList![index - 1];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Avatar(reply.userId, reply.avatarUrl, 12.w),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // No inner Row needed
                      Text(
                        reply.content,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}