import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/transcribe_voice_message_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_system_api_manager.dart';
import 'package:quick_share_app/components/avatar.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/dto/voice_message_dto.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/add_voice_message_page_screen.dart';
import 'package:quick_share_app/features/voice_message_page_feature/components/play_stop_button.dart';
import 'package:quick_share_app/features/voice_message_page_feature/components/response_diolog/response_dialog.dart';
import 'package:quick_share_app/features/voice_message_page_feature/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/utils/string_utils.dart';
import 'package:quick_share_app/utils/time_utils.dart';

import '../../../config/color.dart';
import '../../../design_system/components/podcoin.dart';
import '../controllers/message_response_player_controller.dart';

class VoiceMessageList extends ConsumerWidget {
  final MessageResponsePlayerController _playerController;

  VoiceMessageList(this._playerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<VoiceMessageDto> voiceMessageList = ref.watch(voiceMessageListProvider);
    return ListView.builder(
      shrinkWrap: true,  // Make the ListView take up only the space it needs
      physics: BouncingScrollPhysics(),  // Disable ListView's own scrolling
      itemCount: voiceMessageList.length,  // Number of items
      itemBuilder: (context, index) {
        return voiceMessageGroup(context, ref, index, voiceMessageList[index]);
      },
    );
  }

  Widget voiceMessageGroup(BuildContext context, WidgetRef ref, int index, VoiceMessageDto voiceMessageDto) {
    List<Widget> responseList = [];
    for(ResponseDto responseDto in voiceMessageDto.responseList?? []) {
      responseList.add(response(ref, responseDto));
    }
    
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.w), // Adjust the radius value as needed
            ),
          ),
          width: 265.w,
          height: 85.h + 110.h * responseList.length,
        ),
        Column(
          key: ref.watch(voiceMessageWidgetKey)[index],
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            voiceMessage(context, ref, index, voiceMessageDto),
            ...responseList
          ],
        )
      ]
    );
  }

  Widget voiceMessage(BuildContext context, WidgetRef ref, int index, VoiceMessageDto voiceMessageDto) {
    Widget statusWidget;
    switch (voiceMessageDto.addStatus) {
      case "received":
        statusWidget = received(ref, context, voiceMessageDto);
        break;
      case "adding":
        statusWidget = adding();
        break;
      case "added":
        statusWidget = added();
        break;
      default:
        statusWidget = received(ref, context, voiceMessageDto);
        break;
    }
    return Container(
      margin: EdgeInsets.only(bottom: 10.w, left: 15.w, right: 15.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.w),
        color: Colors.white,
        boxShadow: DesignSystem.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Avatar(
                voiceMessageDto.listenerId,
                voiceMessageDto.listenerAvatarImageUrl,
                36.w,
              ),
              SizedBox(width: 8.w),
              SizedBox(
                height: 36.w,
                width: 160.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(StringUtils.shorten(voiceMessageDto.listenerName, 12)),
                        SizedBox(width: 4.w,),
                        Visibility(
                          visible: voiceMessageDto.donateAmount != 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.w),
                                color: DesignColor.secondary500
                            ),
                            child: Row(
                              children: [
                                PodCoin(size: 12.w),
                                SizedBox(width: 2,),
                                Text(
                                  voiceMessageDto.donateAmount.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white
                                  ),
                                )
                              ],
                            )
                          )
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(TimeUtils.timeAgo(voiceMessageDto.uploadTime)),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              statusWidget,
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              PlayStopButton(
                _playerController,
                voiceMessageDto.voiceMessageId,
                voiceMessageDto.url,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ProgressBar(
                  progress: ref.watch(focusAudioIdProvider) ==
                      voiceMessageDto.voiceMessageId
                      ? ref.watch(messagePlayerProgressProvider)
                      : Duration.zero,
                  thumbRadius: 6.w,
                  barHeight: 4.w,
                  thumbColor: DesignColor.primary50,
                  baseBarColor: DesignColor.neutral40,
                  progressBarColor: ConfigColor.primaryDefault,
                  total: Duration(milliseconds: voiceMessageDto.length),
                  onSeek: (duration) {
                    if (ref.watch(focusAudioIdProvider) ==
                        voiceMessageDto.voiceMessageId) {
                      _playerController.seekPosition(duration);
                    }
                  },
                  timeLabelLocation: TimeLabelLocation.sides,
                ),
              ),
              SizedBox(width: 8.w,),
              responseButton(ref, context, voiceMessageDto)
            ],
          ),
          const SizedBox(height: 8,),
          Visibility(
            visible: voiceMessageDto.transcription != null,
            child: Text(
              voiceMessageDto.transcription?? "",
            )
          )
        ],
      ),
    );
  }

  Widget responseButton(WidgetRef ref, BuildContext context, VoiceMessageDto voiceMessageDto) {
    return Visibility(
      visible: voiceMessageDto.addStatus == "received",
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              if(ref.watch(transcribingVoiceMessageIdProvider) != null) {
                return;
              }
              ref.watch(transcribingVoiceMessageIdProvider.notifier).state = voiceMessageDto.voiceMessageId;
              TranscribeVoiceMessageRes response = await voiceMessageApiManager.transcribeVoiceMessage(voiceMessageDto.voiceMessageId);
              if(response.code != "0000") {
                ToastService.showNoticeToast("轉文字失敗");
                ref.watch(transcribingVoiceMessageIdProvider.notifier).state = null;
                return;
              }
              List<VoiceMessageDto> currentVoiceMessageList = ref.watch(voiceMessageListProvider);
              for(int i = 0; i < currentVoiceMessageList.length; i++) {
                if(currentVoiceMessageList[i].voiceMessageId == voiceMessageDto.voiceMessageId) {
                  currentVoiceMessageList[i].transcription = response.text;
                  break;
                }
              }
              ref.watch(voiceMessageListProvider.notifier).state = [...currentVoiceMessageList];
              ref.watch(transcribingVoiceMessageIdProvider.notifier).state = null;
            },
            child: ref.watch(transcribingVoiceMessageIdProvider) == voiceMessageDto.voiceMessageId? SizedBox(
              width: 18.w,
              height: 18.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DesignColor.actpodPrimary400,
              ),
            ) : Row(
              children: [
                Icon(
                  Icons.text_fields_rounded,
                  size: 18.w,
                ),
                SizedBox(width: 2.w,),
                Text(
                  "轉文字",
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignColor.neutral600,
                  ),
                )
              ],
            )
          ),
          const SizedBox(width: 4,),
          InkWell(
            onTap: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return ResponseDialogScreen(context, voiceMessageDto);
                }
              ).then((responseDto) {
                if(responseDto != null) {
                  List<VoiceMessageDto> currentVoiceMessageList = ref.watch(voiceMessageListProvider);
                  for(int i = 0; i < currentVoiceMessageList.length; i++) {
                    if(currentVoiceMessageList[i].voiceMessageId == voiceMessageDto.voiceMessageId) {
                      currentVoiceMessageList[i].responseList?.add(responseDto);
                      break;
                    }
                  }
                  ref.watch(voiceMessageListProvider.notifier).state = [...currentVoiceMessageList];
                }
              });
            },
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/icons/send_circle_outlined.svg",
                  color: DesignColor.neutral600,
                  width: 18.w,
                  height: 18.w,
                ),
                SizedBox(width: 2.w,),
                Text(
                  "回覆",
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignColor.neutral600,
                  ),
                )
              ],
            )
          )
        ]
      )
    );
  }

  Widget received(WidgetRef ref, BuildContext context, VoiceMessageDto voiceMessageDto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: voiceMessageDto.storyOwnerId == UserService.getUserInfo()?.userId && voiceMessageDto.acceptAdd == "reject",
          child: Text(
            "不接受添加",
            style: TextStyle(
              fontSize: 12,
              color: DesignColor.neutral600
            ),
          )
        ),
        Visibility(
          visible: voiceMessageDto.storyOwnerId == UserService.getUserInfo()?.userId && (voiceMessageDto.acceptAdd == "accept" || voiceMessageDto.acceptAdd == ""),
          child: InkWell(
            onTap: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AddVoiceMessagePageScreen(voiceMessageDto);
                }
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 18.w,
                  color: DesignColor.neutral600
                ),
                SizedBox(width: 2.w,),
                Text(
                  "加入語音內容",
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignColor.neutral600
                  ),
                )
              ],
            )
          )
        )
      ],
    );
  }

  Widget adding() {
    return Text(
      "添加中...",
      style: TextStyle(
        color: DesignColor.neutral600,
        fontSize: 12
      ),
    );
  }

  Widget added() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: DesignColor.actpodPrimary100
      ),
      child: Text(
        "已加入語音內容",
        style: TextStyle(
          fontSize: 12,
          color: DesignColor.actpodPrimary950
        ),
      )
    );
  }

  Widget response(WidgetRef ref, ResponseDto responseDto) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h, right: 16.w),
      width: 260.w,
      height: 100.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.w),
          color: Colors.white,
          boxShadow: DesignSystem.shadow
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Avatar(responseDto.userId, responseDto.userAvatarImageUrl, 34.w),
                SizedBox(width: 8.w,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      responseDto.userName
                    ),
                    Text(TimeUtils.timeAgo(responseDto.uploadTime))
                  ],
                )
              ],
            ),
            SizedBox(height: 10.h,),
            Row(
              children: [
                PlayStopButton(_playerController, responseDto.responseId, responseDto.url),
                SizedBox(width: 5.w,),
                Expanded(
                  child: ProgressBar(
                    progress: ref.watch(focusAudioIdProvider) == responseDto.responseId? ref.watch(messagePlayerProgressProvider) : Duration.zero,
                    thumbRadius: 6.w,
                    barHeight: 4.h,
                    thumbColor: DesignColor.primary50,
                    baseBarColor: DesignColor.neutral40,
                    progressBarColor: DesignColor.primary50,
                    total: Duration(milliseconds: responseDto.length),
                    onSeek: (duration) {
                      if(ref.watch(focusAudioIdProvider) == responseDto.responseId) {
                        _playerController.seekPosition(duration);
                      }
                    },
                    timeLabelLocation: TimeLabelLocation.sides,
                  ),
                )
              ],
            ),
          ],
        )
      ),
    );
  }
}