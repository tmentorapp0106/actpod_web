import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/dto/sound_effect_list_item_dto.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_timer_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/list_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/music_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/upload_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/pages/upload_audio_page.dart';
import 'package:quick_share_app/utils/time_utils.dart';

import '../../../../apiManagers/audio_library_api_dto/find_audios_res.dart';
import '../../../../dto/block_info_dto.dart';
import '../../const/const.dart';
import '../../controllers/edit_trim_player_controller.dart';
import '../../providers.dart';

class SoundEffectSelectModal extends ConsumerWidget {
  final MusicPlayerController _musicPlayerController;
  final EditTrimPlayerTimerController _playerTimerController;
  final EditTrimPlayController _playController;
  final UploadController _uploadController;
  final ListController _listController;

   SoundEffectSelectModal(this._musicPlayerController, this._playerTimerController, this._playController, this._uploadController, this._listController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dragBar(),
          SizedBox(height: 10.h,),
          title(),
          SizedBox(height: 10.h,),
          Row(
            children: [
              tags(ref),
              const Spacer(),
              upload(context)
            ],
          ),
          SizedBox(
            height: 200.h,
            child: ref.watch(searchAudioTypeProvider) == "actpod"? actpodSoundEffectList(ref) : personalSoundEffectList(ref)
          )
        ],
      )
    );
  }

  Widget actpodSoundEffectList(WidgetRef ref) {
    List<SoundEffectListItemDto> soundEffectList = ref.watch(soundEffectListProvider);

    return ListView.builder(
      itemCount: soundEffectList.length,
      itemBuilder: (context, index) {
        return actpodSoundEffectSelectItem(soundEffectList[index], ref, context);
      },
    );
  }

  Widget personalSoundEffectList(WidgetRef ref) {
    List<FindAudiosResItem> soundEffectList = ref.watch(soundAudiosProvider);

    return ListView.builder(
      itemCount: soundEffectList.length,
      itemBuilder: (context, index) {
        return personalSoundEffectSelectItem(soundEffectList[index], ref, context);
      },
    );
  }

  Widget upload(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return UploadAudioPage(_uploadController, _listController, "sound");
        }));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Text(
          "上傳音檔",
          style: TextStyle(
            fontSize: 16.w,
            color: Colors.white
          ),
        ),
      )
    );
  }

  Widget tags(WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              ref.watch(searchAudioTypeProvider.notifier).state = "actpod";
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
              decoration: BoxDecoration(
                color: ref.watch(searchAudioTypeProvider) == "actpod"? ConfigColor.primaryDefault : const Color(0xfff2f2f2),
                borderRadius: BorderRadius.circular(16.w)
              ),
              child: Text(
                "官方",
                style: TextStyle(
                  fontSize: 16.w,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w,),
          GestureDetector(
            onTap: () {
              ref.watch(searchAudioTypeProvider.notifier).state = "personal";
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
              decoration: BoxDecoration(
                color: ref.watch(searchAudioTypeProvider) == "personal"? ConfigColor.primaryDefault : const Color(0xfff2f2f2),
                borderRadius: BorderRadius.circular(16.w)
              ),
              child: Text(
                "個人",
                style: TextStyle(
                  fontSize: 16.w,
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget title() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        "加入音效",
        style: TextStyle(
          fontSize: 16.w,
          fontWeight: FontWeight.bold,
          color: Colors.white
        ),
      )
    );
  }

  Widget dragBar() {
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

  Widget actpodSoundEffectSelectItem(SoundEffectListItemDto dto, WidgetRef ref, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          SvgPicture.network(
            dto.soundEffectImageUrl,
            width: 26.w,
            height: 26.w,
            fit: BoxFit.contain,
            color: Colors.white,
          ),
          SizedBox(width: 5.w,),
          Text(
            dto.soundEffectName,
            style: TextStyle(
              fontSize: 16.w,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            ref.watch(musicPlayingUrlProvider) == dto.soundEffectUrl? TimeUtils.formatDuration(Duration(milliseconds: dto.soundEffectLength) - ref.watch(musicPlayerDurationProvider), "mm:ss") : TimeUtils.formatDuration(Duration(milliseconds: dto.soundEffectLength), "mm:ss"),
            style: TextStyle(
              fontSize: 12.w,
              color: Colors.white
            ),
          ),
          SizedBox(width: 5.w,),
          GestureDetector(
            onTap: () async {
              if (ref.watch(musicPlayerStatusProvider) == "paused" && ref.watch(musicPlayingUrlProvider) != dto.soundEffectUrl) {
                _musicPlayerController.playMusic(dto.soundEffectUrl);
              } else if (ref.watch(musicPlayerStatusProvider) == "paused" && ref.watch(musicPlayingUrlProvider) == dto.soundEffectUrl) {
                _musicPlayerController.restartMusic();
              } else if (ref.watch(musicPlayerStatusProvider) == "playing" && ref.watch(musicPlayingUrlProvider) == dto.soundEffectUrl) {
                _musicPlayerController.pauseMusic();
              } else {
                await _musicPlayerController.pauseMusic();
                _musicPlayerController.playMusic(dto.soundEffectUrl);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: DesignSystem.borderGrey
                ),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(0.w),
              child: Icon(
                ref.watch(musicPlayingUrlProvider) == dto.soundEffectUrl && ref.watch(musicPlayerStatusProvider) == "playing"? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: DesignSystem.borderGrey,
                size: 20.w
              )
            ),
          ),
          SizedBox(width: 5.w,),
          InkWell(
            onTap: () async {
              // 如果太靠近邊界則認定是要選取邊界
              Duration currentPosition = _playerTimerController.getCursor();
              int blockIndex = 0;
              List<BlockInfoDto> blockInfoList = ref.watch(blockInfosProvider);
              for(int i = 0; i < blockInfoList.length; i++) {
                if(blockInfoList[i].from <= currentPosition && blockInfoList[i].to > currentPosition) {
                  blockIndex = i;
                }
              }
              if(currentPosition - blockInfoList[blockIndex].from < edgeLimit) {
                await _playController.seekPosition(blockInfoList[blockIndex].from.inMilliseconds, stopTrackFirst: true);
              } else if(blockInfoList[blockIndex].to - currentPosition < edgeLimit) {
                await _playController.seekPosition(blockInfoList[blockIndex].to.inMilliseconds, stopTrackFirst: true);
              }

              await _playController.insertSound(dto.soundEffectUrl, dto.soundEffectName, "soundEffect");
              Navigator.pop(context, dto);
            },
            child: Container(
              width: 40.w,
              height: 25.h,
              padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 1.h, bottom: 2.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.w),
                color: DesignSystem.primary500
              ),
              child: Center(
                child: AutoSizeText(
                  "插入",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              )
            )
          ),
          SizedBox(width: 5.w,),
          InkWell(
            onTap: () async {
              await _playController.overlapSoundEffect(soundEffectListItemDto: dto);
              Navigator.pop(context, dto);
            },
            child: Container(
              width: 40.w,
              height: 25.h,
              padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 1.h, bottom: 2.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.w),
                color: DesignSystem.primary500
              ),
              child: Center(
                child: AutoSizeText(
                  "重疊",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              )
            )
          )
        ],
      )
    );
  }

  Widget personalSoundEffectSelectItem(FindAudiosResItem dto, WidgetRef ref, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Text(
            dto.audioName,
            style: TextStyle(
              fontSize: 16.w,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Text(
            ref.watch(musicPlayingUrlProvider) == dto.audioUrl? TimeUtils.formatDuration(Duration(milliseconds: dto.length) - ref.watch(musicPlayerDurationProvider), "mm:ss") : TimeUtils.formatDuration(Duration(milliseconds: dto.length), "mm:ss"),
            style: TextStyle(
                fontSize: 12.w,
                color: Colors.white
            ),
          ),
          SizedBox(width: 5.w,),
          GestureDetector(
            onTap: () async {
              if (ref.watch(musicPlayerStatusProvider) == "paused" && ref.watch(musicPlayingUrlProvider) != dto.audioUrl) {
                _musicPlayerController.playMusic(dto.audioUrl);
              } else if (ref.watch(musicPlayerStatusProvider) == "paused" && ref.watch(musicPlayingUrlProvider) == dto.audioUrl) {
                _musicPlayerController.restartMusic();
              } else if (ref.watch(musicPlayerStatusProvider) == "playing" && ref.watch(musicPlayingUrlProvider) == dto.audioUrl) {
                _musicPlayerController.pauseMusic();
              } else {
                await _musicPlayerController.pauseMusic();
                _musicPlayerController.playMusic(dto.audioUrl);
              }
            },
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: DesignSystem.borderGrey
                  ),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(0.w),
                child: Icon(
                    ref.watch(musicPlayingUrlProvider) == dto.audioUrl && ref.watch(musicPlayerStatusProvider) == "playing"? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: DesignSystem.borderGrey,
                    size: 20.w
                )
            ),
          ),
          SizedBox(width: 5.w,),
          InkWell(
            onTap: () async {
              // 如果太靠近邊界則認定是要選取邊界
              Duration currentPosition = _playerTimerController.getCursor();
              int blockIndex = 0;
              List<BlockInfoDto> blockInfoList = ref.watch(blockInfosProvider);
              for(int i = 0; i < blockInfoList.length; i++) {
                if(blockInfoList[i].from <= currentPosition && blockInfoList[i].to > currentPosition) {
                  blockIndex = i;
                }
              }
              if(currentPosition - blockInfoList[blockIndex].from < edgeLimit) {
                await _playController.seekPosition(blockInfoList[blockIndex].from.inMilliseconds, stopTrackFirst: true);
              } else if(blockInfoList[blockIndex].to - currentPosition < edgeLimit) {
                await _playController.seekPosition(blockInfoList[blockIndex].to.inMilliseconds, stopTrackFirst: true);
              }

              await _playController.insertSound(dto.audioUrl, dto.audioName, "soundEffect");
              Navigator.pop(context, dto);
            },
            child: Container(
              width: 40.w,
              height: 25.h,
              padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 1.h, bottom: 2.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.w),
                color: DesignSystem.primary500
              ),
              child: Center(
                child: AutoSizeText(
                  "插入",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              )
            )
          ),
          SizedBox(width: 5.w,),
          InkWell(
              onTap: () async {
                await _playController.overlapSoundEffect(findAudioResItem: dto);
                Navigator.pop(context, dto);
              },
              child: Container(
                  width: 40.w,
                  height: 25.h,
                  padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 1.h, bottom: 2.h),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.w),
                      color: DesignSystem.primary500
                  ),
                  child: Center(
                      child: AutoSizeText(
                        "重疊",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                  )
              )
          )
        ],
      )
    );
  }
}