import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/get_one_story_res.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/components/channel_image.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/dto/short_dto.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../dto/player_item_dto.dart';

class ShortsVideo extends ConsumerStatefulWidget {
  final ShowShortDto short;
  final YoutubePlayerController controller;
  final int pageIndex;
  final int currentIndex;

  const ShortsVideo({
    super.key,
    required this.short,
    required this.controller,
    required this.pageIndex,
    required this.currentIndex,
  });

  @override
  ConsumerState<ShortsVideo> createState() => _ShortsPageState();
}

class _ShortsPageState extends ConsumerState<ShortsVideo>
    with AutomaticKeepAliveClientMixin {
  bool _ready = false;
  bool _loadingStory = false;
  bool _navigated = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(covariant ShortsVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When this page becomes visible, try to play (if ready)
    if (_ready && widget.pageIndex == widget.currentIndex) {
      _autoplayIOSSafe();
    } else if (_ready && widget.pageIndex != widget.currentIndex) {
      widget.controller.pause();
    }
  }

  void _autoplayIOSSafe() {
    if(ref.watch(mainPlayerStatusProvider) == MainPlayerState.playing || _navigated) {
      widget.controller.pause();
    } else {
      widget.controller.seekTo(Duration.zero);
      widget.controller.unMute();
      widget.controller.play();
    }
  }

  Future<void> _gotoStory(String storyId) async {
    setState(() {
      _loadingStory = true;
    });
    GetOneStoryRes response = await storyApiManager.getOneStory(storyId);
    if(response.code != "0000") {
      setState(() {
        _loadingStory = false;
      });
      return;
    }
    if(response.story == null) {
      setState(() {
        _loadingStory = false;
      });
      return;
    }
    setState(() {
      _loadingStory = false;
    });
    List<PlayerItemDto> playList = [PlayerItemDto.fromGetOneStoryResItem(response.story!)];
    _navigated = true;
    await router.push("/story/multiple", extra: {"playerItemList": playList, "index": 0});
    _navigated = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.controller.value.isPlaying) {
                widget.controller.pause();
              } else {
                widget.controller.play();
              }
            },
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: YoutubePlayer(
                controller: widget.controller,
                showVideoProgressIndicator: false,
                onReady: () {
                  _ready = true;
                  widget.controller.seekTo(const Duration(seconds: 1));
                  if (widget.pageIndex == widget.currentIndex) {
                    _autoplayIOSSafe();
                  }
                },
              ),
            )
          ),
          Positioned(
            bottom: 0.h,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  goto(widget.short.storyId),
                  const SizedBox(height: 8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 280.w,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                channelImage(ref, widget.short.channelImageUrl, widget.short.channelId),
                                const SizedBox(width: 8,),
                                channelName(widget.short.channelName)
                              ],
                            ),
                            storyName(widget.short.storyName)
                          ]
                        )
                      ),
                      const Spacer(),
                      storyImage(widget.short.storyId, widget.short.storyImageUrl),
                    ]
                  ),
                ]
              )
            )
          )
        ]
      )
    );
  }

  Widget goto(String storyId) {
    return GestureDetector(
      onTap: () {
        if(_loadingStory) {
          return;
        }
        _gotoStory(storyId);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "前往收聽",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
          ),
          Icon(
            Icons.arrow_forward,
            color: Colors.white,
          )
        ]
      )
    );
  }

  Widget storyName(String name) {
    return Text(
      name,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20
      ),
    );
  }
  
  Widget channelName(String name) {
    return Text(
      name,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20
      ),
    );
  }

  Widget channelImage(WidgetRef ref, String url, String channelId) {
    return GestureDetector(
      onTap: () async {
        _navigated = true;
        ref.watch(mainPageIndexProvider.notifier).state = 0; // for showing mini player
        await router.push("/channel/$channelId");
        ref.watch(mainPageIndexProvider.notifier).state = 1;
        _navigated = false;
      },
      child: SizedBox(
        width: 40,
        height: 40,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: Image.network(
              url,
            )
          )
        )
      )
    );
  }

  Widget storyImage(String storyId, String url) {
    return GestureDetector(
      onTap: () {
        if(_loadingStory) {
          return;
        }
        _gotoStory(storyId);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h, right: 8.w),
        width: 60,
        height: 60,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Image.network(
                  url,
                )
              )
            ),
            Visibility(
              visible: _loadingStory,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: DesignColor.actpodPrimary400,
                  )
                )
              )
            ),
          ]
        )
      )
    );
  }
}