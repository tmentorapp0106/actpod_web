import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/comment_controller.dart';
import 'package:quick_share_app/services/audio_service.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/utils/time_utils.dart';

import '../../../components/avatar.dart';
import '../../../design_system/color.dart';
import '../../../design_system/components/podcoin.dart';
import '../../../dto/comment_dto.dart';
import '../../../main.dart';
import '../../../providers.dart';
import '../../../services/user_service.dart';
import '../../../utils/string_utils.dart';
import '../../login_feature/login_screen.dart';
import '../providers.dart';

class InstantCommentBottomModel {
  final podcoinOptions = [0, 10, 20, 30, 50, 70, 100, 200, 500, 1000, 2000, 5000];
  final TextEditingController _textController = TextEditingController();
  final FocusNode focusNode;
  final CommentController commentController;
  final PlayerItemDto storyInfo;


  InstantCommentBottomModel({
    required this.focusNode,
    required this.commentController,
    required this.storyInfo
  });

  Widget commentList(WidgetRef ref, List<InstantCommentInfoDto>? comments, ScrollController scrollController) {
    if(comments == null) {
      return const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            color: DesignColor.primary50,
            strokeWidth: 4,
          ),
        ),
      );
    }
    if(comments.length == 0) {
      return const Center(
        child: Text(
          "成為第一個留言的人吧！"
        ),
      );
    }

    return ListView.builder(
      controller: scrollController, // important
      padding: EdgeInsets.symmetric(horizontal: 12.w).copyWith(bottom: 20.h),
      itemCount: comments.length,
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
                  SizedBox(width: 2.w),
                  Text(
                    StringUtils.shorten(comment.nickname, 10),
                    style: TextStyle(
                      fontSize: 14.w,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: () {
                      if(actPodAudioHandler?.mediaItem.value?.id != storyInfo.storyId) {
                        ToastService.showNoticeToast("尚未收聽，無法為您跳轉");
                        return;
                      }
                      if(ref.watch(isPlayingInteractiveContentProvider)) {
                        ToastService.showNoticeToast("正在播放語音留言中，無法跳轉");
                        return;
                      }
                      actPodAudioHandler?.seek(Duration(seconds: comment.sendSecond - 1 <= 0? 0 : comment.sendSecond - 1));
                      if(context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      TimeUtils.formatDuration(Duration(seconds: comment.sendSecond), "HH:mm:ss"),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blueAccent,
                      ),
                    )
                  ),
                  SizedBox(width: 8.w),
                  Visibility(
                    visible: comment.podcoins != 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w, vertical: 1.h),
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
                            comment.podcoins.toString(),
                            style: const TextStyle(
                              color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(comment.content),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> show(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          final viewInsets = MediaQuery.of(context).viewInsets; // includes keyboard
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.decelerate,
                padding: EdgeInsets.only(bottom: viewInsets.bottom),
                child: Consumer(
                  builder: (context, ref, _) {
                    final comments = ref.watch(instantCommentListProvider);

                    return Column(
                      children: [
                        // Header
                        Padding(
                          padding: EdgeInsets.only(top: 12.h, left: 12.w, right: 12.w),
                          child: Center(
                            child: Text(
                              "即時留言",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.w),
                            ),
                          ),
                        ),

                        // Scrollable list (takes the remaining space)
                        Expanded(
                          child: commentList(ref, comments, scrollController)
                        ),

                        // Input bar
                        Padding(
                          padding:
                          EdgeInsets.only(left: 12.w, right: 12.w, bottom: 20.h),
                          child: Column(
                            children: [
                              Visibility(
                                  visible: ref.watch(instantInputFocusProvider),
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
                                          Text(
                                              "剩餘 Podcoin: ${ref.watch(userPodCoinsProvider)}"
                                          ),
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
                                                      color: isSelected? DesignColor.actpodPrimary100 : Colors.white,
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
                                  Avatar(null, UserService.getUserInfo()?.avatarUrl, 24.w),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: TextField(
                                      focusNode: focusNode,
                                      controller: _textController,
                                      minLines: 1,
                                      maxLines: 2,
                                      textInputAction: TextInputAction.newline,
                                      decoration: InputDecoration(
                                        hintText: "傳送即時留言...",
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      if (ref.watch(instantSendingProvider)) return;
                                      if (_textController.text.isEmpty) return;
                                      if (!UserService.hasLoggedIn()) {
                                        showDialog(context: context, builder: (_) => LoginPageScreen());
                                        return;
                                      }

                                      final playingItem = actPodAudioHandler?.mediaItem.value;
                                      if (ref.watch(mainPlayerPositionProvider).inSeconds == 0 ||
                                          storyInfo.storyId != playingItem?.id) {
                                        ToastService.showNoticeToast("請開始聆聽故事後再開始留言");
                                        return;
                                      }
                                      if(ref.watch(isPlayingInteractiveContentProvider)) {
                                        ToastService.showNoticeToast("語音留言內容無法傳送訊息");
                                        return;
                                      }

                                      // prefer read() when writing
                                      ref.read(instantSendingProvider.notifier).state = true;
                                      await commentController.createInstantComment(
                                        storyInfo.storyId,
                                        _textController.text,
                                        ref.watch(mainPlayerPositionProvider).inSeconds,
                                        ref.watch(selectedDonateAmountProvider),
                                      );
                                      ref.read(instantSendingProvider.notifier).state = false;

                                      _textController.clear();
                                      if (context.mounted) Navigator.of(context).pop(true);
                                    },
                                    child: ref.watch(instantSendingProvider)
                                        ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: DesignColor.primary50,
                                      ),
                                    ) : const Icon(Icons.send, size: 24, color: DesignColor.primary50),
                                  ),
                                ],
                              ),
                            ]
                          )
                        ),
                      ],
                    );
                  },
                ),
              );
            }
          );
        }
    );
  }
}