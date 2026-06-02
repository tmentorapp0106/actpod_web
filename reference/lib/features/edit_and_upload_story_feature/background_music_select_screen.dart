import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/dto/backgournd_music_list_item_dto.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/providers.dart';
import 'package:quick_share_app/utils/time_utils.dart';

import '../../config/color.dart';
import 'controllers/music_player_controller.dart';

class BackgroundMusicSelectScreen extends ConsumerWidget {
  final MusicPlayerController _musicPlayerController;

  BackgroundMusicSelectScreen(this._musicPlayerController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<BackgroundMusicListItemDto> backgroundMusicList = ref.watch(backgroundMusicListProvider);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "加入背景音樂",
            style: TextStyle(
              fontSize: 16.w,
              color: ConfigColor.textColorDefault,
              fontWeight: FontWeight.bold
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            ),
          ),
          elevation: 0,
          backgroundColor: ConfigColor.background,
        ),
        backgroundColor: ConfigColor.background,
        body: SafeArea(
          child: ListView.builder(
            itemCount: backgroundMusicList.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return backgroundMusicSelectItem(backgroundMusicList[index], context, ref);
            },
          ),
        )
    );
  }

  Widget backgroundMusicSelectItem(BackgroundMusicListItemDto dto, BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(3.w)
            ),
          ),
          SizedBox(width: 5.w,),
          Text(
            dto.backgroundMusicName,
            style: TextStyle(
              fontSize: 18.w
            ),
          ),
          const Spacer(),
          Text(
            ref.watch(musicPlayingUrlProvider) == dto.backgroundMusicUrl? TimeUtils.formatDuration(Duration(milliseconds: dto.backgroundMusicLength) - ref.watch(musicPlayerDurationProvider), "mm:ss") : TimeUtils.formatDuration(Duration(milliseconds: dto.backgroundMusicLength), "mm:ss"),
            style: TextStyle(
              fontSize: 12.w
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
                border: Border.all(width: 1),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(0.w),
              child: Icon(
                  ref.watch(musicPlayingUrlProvider) == dto.backgroundMusicUrl && ref.watch(musicPlayerStatusProvider) == "playing"? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 20.w
              )
            )
          ),
          SizedBox(width: 5.w,),
          InkWell(
            onTap: () {
              Navigator.pop(context, dto);
            },
            child: Container(
              width: 40.w,
              height: 25.h,
              padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 1.h, bottom: 2.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.w),
                color: Colors.grey
              ),
              child: Center(
                child: AutoSizeText(
                  "使用",
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