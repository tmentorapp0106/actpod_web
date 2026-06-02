import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_timer_controller.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';

import '../../../../apiManagers/audio_library_api_dto/find_audios_res.dart';
import '../../../../config/color.dart';
import '../../../../design_system/design.dart';
import '../../../../dto/backgournd_music_list_item_dto.dart';
import '../../../../dto/block_info_dto.dart';
import '../../../../utils/time_utils.dart';
import '../../const/const.dart';
import '../../controllers/list_controller.dart';
import '../../controllers/music_player_controller.dart';
import '../../controllers/upload_controller.dart';
import '../../pages/upload_audio_page.dart';

class MusicSelectModel extends ConsumerWidget {
  final MusicPlayerController _musicPlayerController;
  final EditTrimPlayerTimerController _playerTimerController;
  final EditTrimPlayController _playController;
  final UploadController _uploadController;
  final ListController _listController;

  MusicSelectModel(this._musicPlayerController, this._playerTimerController, this._playController, this._uploadController, this._listController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<BackgroundMusicListItemDto> musicList = ref.watch(backgroundMusicListProvider);

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
            child: ref.watch(searchAudioTypeProvider) == "actpod"? actpodMusicList(ref) : personalMusicList(ref)
          )
        ],
      )
    );
  }

  Widget actpodMusicList(WidgetRef ref) {
    List<BackgroundMusicListItemDto> actpodMusicList = ref.watch(backgroundMusicListProvider);

    return ListView.builder(
      itemCount: actpodMusicList.length,
      itemBuilder: (context, index) {
        return musicSelectItem(actpodMusicList[index], ref, context);
      },
    );
  }

  Widget personalMusicList(WidgetRef ref) {
    List<FindAudiosResItem> personalMusicList = ref.watch(musicAudiosProvider);

    return ListView.builder(
      itemCount: personalMusicList.length,
      itemBuilder: (context, index) {
        return personalMusicSelectItem(personalMusicList[index], ref, context);
      },
    );
  }

  Widget title() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        "加入音樂",
        style: TextStyle(
            fontSize: 16.w,
            fontWeight: FontWeight.bold,
            color: Colors.white
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

  Widget upload(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return UploadAudioPage(_uploadController, _listController, "music");
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

  Widget musicSelectItem(BackgroundMusicListItemDto dto, WidgetRef ref, BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            SvgPicture.network(
              dto.backgroundMusicImageUrl,
              width: 26.w,
              height: 26.w,
              fit: BoxFit.contain,
              color: Colors.white,
            ),
            SizedBox(width: 5.w,),
            Text(
              dto.backgroundMusicName,
              style: TextStyle(
                fontSize: 16.w,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              ref.watch(musicPlayingUrlProvider) == dto.backgroundMusicUrl? TimeUtils.formatDuration(Duration(milliseconds: dto.backgroundMusicLength) - ref.watch(musicPlayerDurationProvider), "mm:ss") : TimeUtils.formatDuration(Duration(milliseconds: dto.backgroundMusicLength), "mm:ss"),
              style: TextStyle(
                fontSize: 12.w,
                color: Colors.white
              ),
            ),
            SizedBox(width: 5.w,),
            GestureDetector(
              onTap: () async {
                if (ref.watch(musicPlayerStatusProvider) == "paused" && ref.watch(musicPlayingUrlProvider) != dto.backgroundMusicUrl) {
                  _musicPlayerController.playMusic(dto.backgroundMusicUrl);
                } else if (ref.watch(musicPlayerStatusProvider) == "paused" && ref.watch(musicPlayingUrlProvider) == dto.backgroundMusicUrl) {
                  _musicPlayerController.restartMusic();
                } else if (ref.watch(musicPlayerStatusProvider) == "playing" && ref.watch(musicPlayingUrlProvider) == dto.backgroundMusicUrl) {
                  _musicPlayerController.pauseMusic();
                } else {
                  await _musicPlayerController.pauseMusic();
                  _musicPlayerController.playMusic(dto.backgroundMusicUrl);
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
                  ref.watch(musicPlayingUrlProvider) == dto.backgroundMusicUrl && ref.watch(musicPlayerStatusProvider) == "playing"? Icons.pause_rounded : Icons.play_arrow_rounded,
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
                await _playController.insertSound(dto.backgroundMusicUrl, dto.backgroundMusicName, "music");
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
                await _playController.overlapBackgroundMusic(dto.backgroundMusicUrl, dto.backgroundMusicName);
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

  Widget personalMusicSelectItem(FindAudiosResItem dto, WidgetRef ref, BuildContext context) {
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
              await _playController.insertSound(dto.audioUrl, dto.audioName, "music");
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
                await _playController.overlapBackgroundMusic(dto.audioUrl, dto.audioName);
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