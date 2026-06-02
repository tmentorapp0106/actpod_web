import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/router.dart';

import '../../../apiManagers/story_api_dto/get_channel_stories_res.dart';
import '../../../dto/live_room_dto.dart';
import '../../../providers.dart';

class StoryBottomSheet extends ConsumerWidget {
  final GetChannelStoriesResItem story;

  StoryBottomSheet(this.story);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
        padding: EdgeInsets.only(top: 15.h, bottom: 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            bar(),
            openLive(context),
          ]
        )
    );
  }

  Widget bar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 3.h,
          width: 50.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: Colors.grey
          ),
        )
      ]
    );
  }

  // Widget editStory(BuildContext context) {
  //   return InkWell(
  //     onTap: () async {
  //       final update = await router.push("/story/${story.storyId}/update");
  //       if(context.mounted) {
  //         Navigator.of(context).pop(update);
  //       }
  //     },
  //     child: Padding(
  //       padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
  //       child: Row(
  //         children: [
  //           Icon(
  //             Icons.edit_rounded
  //           ),
  //           Text(
  //             "編輯故事",
  //             style: TextStyle(
  //               fontSize: 18.sp,
  //             ),
  //           )
  //         ],
  //       ),
  //     )
  //   );
  // }

  Widget openLive(BuildContext context) {
    return InkWell(
        onTap: () async {
          final openResult = await _showOpenLiveDialog(context);
          if (!context.mounted) return;

          // 使用者取消或沒輸入
          if (openResult == null || openResult.title.trim().isEmpty) return;

          if(openResult.mode == LiveRoomMode.interactive) {
            await router.push(
              "/live/interactive/host/${story.storyId}",
              extra: {
                "roomId": "",
                "title": openResult.title.trim(),
                "capacity": openResult.capacity,
                "notifyFans": openResult.notifyFans,
                "notyetOwnedStoryPrice": openResult.notyetOwnedStoryPrice,
                "alreadyOwnedStoryPrice": openResult.alreadyOwnedStoryPrice
              },
            );
          } else {
            await router.push(
              "/live/listen_together/host/${story.storyId}",
              extra: {
                "roomId": "",
                "title": openResult.title.trim(),
                "notifyFans": openResult.notifyFans,
                "notyetOwnedStoryPrice": openResult.notyetOwnedStoryPrice,
                "alreadyOwnedStoryPrice": openResult.alreadyOwnedStoryPrice
              },
            );
          }

          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
          child: Row(
            children: [
              Icon(
                  Icons.live_tv_rounded
              ),
              Text(
                "開啟直播",
                style: TextStyle(
                  fontSize: 18.sp,
                ),
              )
            ],
          ),
        )
    );
  }

  Future<OpenLiveDialogResult?> _showOpenLiveDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final notyetOwnedStoryController = TextEditingController();
    final alreadyOwnedStoryController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    LiveRoomMode selectedMode = LiveRoomMode.listenTogether;
    int selectedCapacity = 10;
    final List<int> capacityOptions = [10, 30, 50];
    bool notifyFans = true;
    bool sellTicket = false;

    return showDialog<OpenLiveDialogResult>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 24.h,
                bottom: bottomInset + 24.h,
              ),
              child: Center(
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 420.w,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                "設定直播房間",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            TapRegion(
                              onTapOutside: (_) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: TextFormField(
                                controller: titleController,
                                autofocus: true,
                                maxLength: 50,
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  hintText: "請輸入房間標題",
                                  counterText: "",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                    borderSide: BorderSide(
                                      color: DesignColor.actpodPrimary500,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                    borderSide: BorderSide(
                                      color: DesignColor.actpodPrimary500,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  final text = value?.trim() ?? "";
                                  if (text.isEmpty) return "請輸入房間標題";
                                  if (text.length < 2) return "至少 2 個字";
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  if (formKey.currentState?.validate() ?? false) {
                                    Navigator.of(dialogContext).pop(
                                      OpenLiveDialogResult(
                                        title: titleController.text.trim(),
                                        mode: selectedMode,
                                        capacity:
                                        selectedMode == LiveRoomMode.interactive
                                            ? selectedCapacity
                                            : null,
                                        notifyFans: notifyFans,
                                        notyetOwnedStoryPrice: int.tryParse(notyetOwnedStoryController.text == ""? "0" : notyetOwnedStoryController.text)!,
                                        alreadyOwnedStoryPrice: int.tryParse(alreadyOwnedStoryController.text == ""? "0" : alreadyOwnedStoryController.text)!,
                                      ),
                                    );
                                  }
                                },
                              )
                            ),

                            SizedBox(height: 12.h),

                            Text(
                              "直播模式",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            RadioGroup<LiveRoomMode>(
                              groupValue: selectedMode,
                              onChanged: (LiveRoomMode? value) {
                                if (value == null) return;
                                setState(() => selectedMode = value);
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RadioListTile<LiveRoomMode>(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: const Text("陪聽"),
                                    subtitle: const Text("同步播放 Podcast 內容"),
                                    value: LiveRoomMode.listenTogether,
                                    activeColor: DesignColor.actpodPrimary500,
                                  ),
                                  // RadioListTile<LiveRoomMode>(
                                  //   contentPadding: EdgeInsets.zero,
                                  //   dense: true,
                                  //   title: const Text("互動"),
                                  //   subtitle: const Text("聽眾可搶麥、拿麥參與"),
                                  //   value: LiveRoomMode.interactive,
                                  //   activeColor: DesignColor.actpodPrimary500,
                                  // ),
                                ],
                              ),
                            ),

                            CheckboxListTile(
                              value: sellTicket,
                              onChanged: (value) {
                                setState(() {
                                  sellTicket = value ?? false;

                                  if (!sellTicket) {
                                    notyetOwnedStoryController.clear();
                                    alreadyOwnedStoryController.clear();
                                  }
                                });
                              },
                              activeColor: DesignColor.actpodPrimary500,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                              title: Text(
                                "販售門票",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                "開啟後，聽眾需要購買門票才能進入互動房",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),

                            if (sellTicket) ...[
                              SizedBox(height: 8.h),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "票價:",
                                    style: TextStyle(
                                      fontSize: 16
                                    ),
                                  ),
                                  const SizedBox(width: 8,),
                                  Expanded(
                                    child: TextFormField(
                                      controller: notyetOwnedStoryController,
                                      keyboardType: TextInputType.number,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        hintText: story.isPremium? "尚未擁有單集" : "直播票價",
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 6.h,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16.r),
                                          borderSide: BorderSide(
                                            color: DesignColor.actpodPrimary500,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16.r),
                                          borderSide: BorderSide(
                                            color: DesignColor.actpodPrimary500,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (!sellTicket) return null;

                                        final text = value?.trim() ?? "";
                                        if (text.isEmpty) return "請輸入票價";

                                        final price = int.tryParse(text);
                                        if (price == null) return "請輸入正確的數字";
                                        if (price < 0) return "票價必須大於等於 0";

                                        return null;
                                      },
                                    ),
                                  ),

                                  if (story.isPremium) ...[
                                    SizedBox(width: 8.w),

                                    Expanded(
                                      child: TextFormField(
                                        controller: alreadyOwnedStoryController,
                                        keyboardType: TextInputType.number,
                                        cursorColor: Colors.black,
                                        decoration: InputDecoration(
                                          hintText: "已擁有單集",
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 6.h,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16.r),
                                            borderSide: BorderSide(
                                              color: DesignColor.actpodPrimary500,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16.r),
                                            borderSide: BorderSide(
                                              color: DesignColor.actpodPrimary500,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (!sellTicket || !story.isPremium) return null;

                                          final text = value?.trim() ?? "";
                                          if (text.isEmpty) return "請輸入已擁有單集的票價";

                                          final alreadyOwnedPrice = int.tryParse(text);
                                          final price = int.tryParse(
                                            notyetOwnedStoryController.text.trim(),
                                          );

                                          if (alreadyOwnedPrice == null) return "請輸入正確的數字";

                                          if (alreadyOwnedPrice < 0) {
                                            return "必須大於等於 0";
                                          }

                                          if (price != null && alreadyOwnedPrice > price) {
                                            return "不能高於直播票價";
                                          }

                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],

                            if (selectedMode == LiveRoomMode.interactive) ...[
                              SizedBox(height: 8.h),

                              Text(
                                "人數上限",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              SizedBox(height: 8.h),

                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.h,
                                children: capacityOptions.map((count) {
                                  final isSelected = selectedCapacity == count;

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(20.r),
                                    onTap: () {
                                      setState(() => selectedCapacity = count);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? DesignColor.actpodPrimary500
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20.r),
                                        border: Border.all(
                                          color: isSelected
                                              ? DesignColor.actpodPrimary500
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Text(
                                        "$count 人",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              SizedBox(height: 12.h),
                            ],

                            CheckboxListTile(
                              value: notifyFans,
                              onChanged: (value) {
                                setState(() {
                                  notifyFans = value ?? true;
                                });
                              },
                              activeColor: DesignColor.actpodPrimary500,
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                              title: Text(
                                "通知粉絲",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                "開播時發送推播給收藏此頻道的聽眾",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(null);
                                  },
                                  child: const Text(
                                    "取消",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (formKey.currentState?.validate() ??
                                        false) {
                                      Navigator.of(dialogContext).pop(
                                        OpenLiveDialogResult(
                                          title: titleController.text.trim(),
                                          mode: selectedMode,
                                          capacity: selectedMode ==
                                              LiveRoomMode.interactive
                                              ? selectedCapacity
                                              : null,
                                          notifyFans: notifyFans,
                                          notyetOwnedStoryPrice: int.tryParse(notyetOwnedStoryController.text == ""? "0" : notyetOwnedStoryController.text)!,
                                          alreadyOwnedStoryPrice: int.tryParse(alreadyOwnedStoryController.text == ""? "0" : alreadyOwnedStoryController.text)!,
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "開啟",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: DesignColor.actpodPrimary500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}