import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/podcoin.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/player_page/controllers/comment_controller.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:actpod_web/utils/cookie_utils.dart';
import 'package:actpod_web/utils/string_utils.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InstantCommentBottomModel {
  final podcoinOptions = [0, 10, 20, 30, 50, 70, 100, 200, 500, 1000, 2000, 5000];
  final TextEditingController _textController = TextEditingController();
  final FocusNode focusNode;
  final CommentController commentController;
  final PlayerController playerController;
  final String storyId;
  // final PlayerItemDto storyInfo;


  InstantCommentBottomModel({
    required this.focusNode,
    required this.commentController,
    required this.storyId,
    required this.playerController
    // required this.storyInfo
  });

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
                          child: comments == null
                              ? const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                color: DesignColor.primary50,
                                strokeWidth: 4,
                              ),
                            ),
                          )
                              : ListView.builder(
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
                                        SizedBox(width: 8.w),
                                        Text(
                                          StringUtils.shorten(comment.nickname, 15),
                                          style: TextStyle(
                                            fontSize: 14.w,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        GestureDetector(
                                          onTap: () {
                                            playerController.seekPosition(Duration(seconds: comment.sendSecond));
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
                                                horizontal: 6.w, vertical: 2.h),
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
                                                      color: Colors.white),
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
                          ),
                        ),

                        // Composer row (fixed at bottom; NOT inside a scroll view)
                        Padding(
                          padding:
                          EdgeInsets.only(left: 12.w, right: 12.w, bottom: 20.h),
                          child: Row(
                            children: [
                              Avatar(null, UserPrefs.getUserInfo()?.avatarUrl, 24.w),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: TextField(
                                  focusNode: focusNode,
                                  controller: _textController,
                                  textInputAction: TextInputAction.send,
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
                                  if (CookieUtils.getCookie("userToken") == null || CookieUtils.getCookie("userToken") == "") {
                                    showDialog(context: context, builder: (_) => LoginScreen());
                                    return;
                                  }

                                  if (ref.watch(audioPositionProvider).inSeconds == 0) {
                                    ToastService.showNoticeToast("請開始聆聽故事後再開始留言");
                                    return;
                                  }

                                  // // prefer read() when writing
                                  ref.watch(instantSendingProvider.notifier).state = true;
                                  await commentController.createInstantComment(
                                    storyId,
                                    _textController.text,
                                    ref.watch(audioPositionProvider).inSeconds,
                                    0,
                                  );
                                  ref.watch(instantSendingProvider.notifier).state = false;

                                  _textController.clear();
                                },
                                child: ref.watch(instantSendingProvider)
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: DesignColor.primary50,
                                  ),
                                )
                                    : const Icon(Icons.send, size: 24, color: DesignColor.primary50),
                              ),
                            ],
                          ),
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