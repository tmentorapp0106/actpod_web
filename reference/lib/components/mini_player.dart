import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/main.dart';

import '../dto/player_item_dto.dart';
import '../providers.dart';
import '../router.dart';
import '../features/play_record_feature/screens/play_record_screen.dart';

class MiniPlayer extends ConsumerWidget {
  final double bottomPadding;

  const MiniPlayer({super.key, required this.bottomPadding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(mainPlayerStoryInfoProvider) != null && ref.watch(mainPageIndexProvider) != 1,
      child: Positioned(
        bottom: bottomPadding,
        child: SizedBox(
        width: ScreenUtil().screenWidth,
        child: InkWell(
          onTap: () {
            List<PlayerItemDto> itemList = [ref.watch(mainPlayerStoryInfoProvider)!];
            router.push("/story/multiple", extra: {"playerItemList": itemList, "index": 0});
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 0.w),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9), // Optional color with transparency
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        color: Color(0xFF000000).withOpacity(0.20),
                        spreadRadius: 0,
                        blurRadius: 20,
                      ),
                    ]
                  ),
                  child: Row(
                    children: [
                      storyImage(ref),
                      SizedBox(width: 5.w,),
                      SizedBox(
                        width: 200.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            storyName(ref),
                            channelName(ref)
                          ],
                        ),
                      ),
                      const Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          playBtn(ref)
                        ],
                      )
                    ],
                  )
                ),
              ),
            ),
            )
          )
        )
      )
    );
  }

  Widget playBtn(WidgetRef ref) {
    if(ref.watch(mainPlayerStatusProvider) == MainPlayerState.loading || ref.watch(mainPlayerStatusProvider) == MainPlayerState.initiating) {
      return SizedBox(
        width: 35.w,
        height: 35.w,
        child: Center(
          child: SizedBox(
            width: 22.w,
            height: 22.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(ConfigColor.primaryDefault),
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        if(ref.watch(mainPlayerStatusProvider) == MainPlayerState.paused) {
          actPodAudioHandler?.play();
        } else {
          actPodAudioHandler?.pause();
        }
      },
      child: Icon(
        ref.watch(mainPlayerStatusProvider) == MainPlayerState.paused? Icons.play_arrow_rounded : Icons.pause_rounded,
        color: ConfigColor.primaryDefault,
        size: 35.w,
      ),
    );
  }

  Widget channelName(WidgetRef ref) {
    PlayerItemDto? playItem = ref.watch(mainPlayerStoryInfoProvider);
    return SizedBox(
      height: 17.w,
      child: Marquee(
        animationDuration: const Duration(seconds: 10),
        directionMarguee: DirectionMarguee.oneDirection,
        child: AutoSizeText(
          playItem == null? "" : playItem.channelName,
          style: TextStyle(
            color: Colors.black,
          )
        )
      )
    );
  }

  Widget storyName(WidgetRef ref) {
    PlayerItemDto? playItem = ref.watch(mainPlayerStoryInfoProvider);
    return SizedBox(
      height: 20.w,
      child: Marquee(
        animationDuration: const Duration(seconds: 10),
        directionMarguee: DirectionMarguee.oneDirection,
        child: AutoSizeText(
          playItem == null? "" : playItem.storyName,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.w,
            fontWeight: FontWeight.bold
          )
        )
      )
    );
  }

  Widget storyImage(WidgetRef ref) {
    PlayerItemDto? storyInfo = ref.watch(mainPlayerStoryInfoProvider);
    return storyInfo == null? const SizedBox.shrink() : AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      child: Opacity(
        key: ValueKey<String>(storyInfo.storyId),
        opacity: 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.network(
            storyInfo.storyImageUrls[0],
            width: 50.w,
            height: 50.w,
            fit: BoxFit.fitWidth,
          )
        )
      )
    );
  }
}