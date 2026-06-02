import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:quick_share_app/apiManagers/channel_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';

import '../../../apiManagers/story_api_dto/get_user_premium_stories_res.dart';
import '../../../components/channel_image.dart';
import '../../../config/color.dart';
import '../../../design_system/components/podcoin.dart';
import '../../../design_system/design.dart';
import '../../../dto/player_item_dto.dart';
import '../../../dto/podcast_store_dto.dart';
import '../../../router.dart';
import '../../../utils/link_utils.dart';
import '../../../utils/time_utils.dart';

class PodcastStoreScreen extends StatefulWidget {
  final PodcastStoreDto? podcastStore;

  const PodcastStoreScreen({super.key, this.podcastStore});

  @override
  State<PodcastStoreScreen> createState() => _PodcastStoreScreenState();
}

class _PodcastStoreScreenState extends State<PodcastStoreScreen> {
  int selectedTabIndex = 1; // 0 = 付費Podcast, 1 = 專屬連結

  bool _isLoading = true;
  bool _loadFailed = false;
  PodcastStoreDto? _podcastStore;
  List<GetUserPremiumStoriesItem>? premiumStories;

  @override
  void initState() {
    super.initState();
    _loadPodcastStore();
    _loadPremiumStories();
  }

  Future<void> _loadPremiumStories() async {
    String? userId;
    if(widget.podcastStore == null) {
      userId = UserService.getUserInfo()!.userId;
    } else {
      userId = widget.podcastStore!.userId;
    }

    GetUserPremiumStoriesRes response = await storyApiManager.getUserPremiumStories(userId);
    if(response.code != "0000") {
      return;
    }
    setState(() {
      premiumStories = response.storyList;
    });
  }

  Future<void> _loadPodcastStore() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    if(widget.podcastStore == null) {
      try {
        final res =
        await channelApiManager.getPodcastStore(UserService.getUserInfo()!.userId);

        if (res.code != "0000" || res.podcastStoreDto == null) {
          setState(() {
            _loadFailed = true;
            _isLoading = false;
          });
          ToastService.showNoticeToast("取得 Podcast Store 資料失敗");
          return;
        }

        setState(() {
          _podcastStore = res.podcastStoreDto;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _loadFailed = true;
          _isLoading = false;
        });
        ToastService.showNoticeToast("取得 Podcast Store 資料失敗");
      }
    } else {
      setState(() {
        _podcastStore = widget.podcastStore;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: DesignColor.actpodPrimary400,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadFailed || _podcastStore == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "無法載入 Podcast Store",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _loadPodcastStore,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFffbc1f),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("重新整理"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final store = _podcastStore!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadPodcastStore,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildTopInfo(store),
                      _buildTabs(),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFBDBDBD),
                      ),
                      const SizedBox(height: 14),
                      selectedTabIndex == 0
                          ? _buildPaidPodcastList()
                          : _buildExclusiveLinksList(store.links),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: SizedBox(
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 24,
                  color: Colors.black,
                ),
              ),
            ),
            if(_isLoading)
              CircularProgressIndicator(
                color: DesignColor.actpodPrimary400,
              ),
            Center(
              child: Text(
                _podcastStore?.name?? "",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  final box = context.findRenderObject() as RenderBox?;
                  SharePlus.instance.share(
                    ShareParams(
                      text: 'https://web.actpodapp.com/podcast_store/${_podcastStore?.userId?? ""}?openExternalBrowser=1',
                      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size
                    )
                  );
                },
                icon: const Icon(
                  Icons.share_rounded,
                  size: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopInfo(PodcastStoreDto store) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(28),
              image: store.storeImageUrl.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(store.storeImageUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: store.storeImageUrl.isEmpty
                ? const Icon(
              Icons.storefront_rounded,
              size: 72,
              color: Colors.black45,
            )
                : null,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              if (store.facebookUrl.isNotEmpty)
                _SocialIcon(
                  svgPath: "assets/icons/facebook.svg",
                  onTap: () {
                    LinkUtils.openLink(store.facebookUrl);
                  },
                ),
              if (store.instagramUrl.isNotEmpty)
                _SocialIcon(
                  svgPath: "assets/icons/instagram.svg",
                  onTap: () {
                    LinkUtils.openLink(store.instagramUrl);
                  },
                ),
              if (store.threadsUrl.isNotEmpty)
                _SocialIcon(
                  svgPath: "assets/icons/threads.svg",
                  onTap: () {
                    LinkUtils.openLink(store.threadsUrl);
                  },
                ),
              if (store.youtubeUrl.isNotEmpty)
                _SocialIcon(
                  svgPath: "assets/icons/youtube.svg",
                  onTap: () {
                    LinkUtils.openLink(store.youtubeUrl);
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              children: [
                ReadMoreText(
                  store.description,
                  style: TextStyle(
                    fontSize: 16
                  ),
                  textAlign: TextAlign.start,
                  trimMode: TrimMode.Line,
                  trimLines: 3,
                  trimCollapsedText: '展開更多',
                  trimExpandedText: '\n隱藏顯示',
                  moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColor.neutral300),
                  lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DesignColor.neutral300),
                  annotations: [
                    // URL
                    Annotation(
                      regExp: RegExp(
                        r'(?:(?:https?|ftp)://)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
                      ),
                      spanBuilder: ({
                        required String text,
                        TextStyle? textStyle,
                      }) {
                        return TextSpan(
                          text: text,
                          style: (textStyle ?? const TextStyle()).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blueAccent,
                            color: Colors.blueAccent,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => LinkUtils.onOpenDescriptionLinkString(text),
                        );
                      },
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: _StoreTab(
              title: "付費Podcast",
              selected: selectedTabIndex == 0,
              onTap: () {
                setState(() {
                  selectedTabIndex = 0;
                });
              },
            ),
          ),
          Expanded(
            child: _StoreTab(
              title: "專屬連結",
              selected: selectedTabIndex == 1,
              onTap: () {
                setState(() {
                  selectedTabIndex = 1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidPodcastList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemCount: premiumStories?.length?? 0,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _storyWidget(context, premiumStories![index]);
      },
    );
  }

  Widget _buildExclusiveLinksList(List<PodcastStoreLinkDto> links) {
    if (links.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Text(
          "目前沒有專屬連結",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      itemCount: links.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final item = links[index];
        return _ExclusiveLinkCard(item: item);
      },
    );
  }

  Widget _storyWidget(BuildContext context, GetUserPremiumStoriesItem story) {
    String lockedString = "";
    if(story.locked) {
      lockedString = "(已上鎖)";
    }
    return InkWell(
      onTap: () {
        List<PlayerItemDto> playerItemList = [PlayerItemDto.fromGetUserPremiumStoriesResItem(story)];
        router.push("/story/multiple", extra: {"playerItemList": playerItemList, "index": 0});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        decoration: BoxDecoration(
            color: Color(0xfffefefe),
            borderRadius: BorderRadius.circular(10.w),
            border: Border.all(
              color: DesignSystem.borderGrey,
            ),
            boxShadow: DesignSystem.shadow
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 140.w,
              height: 140.w,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.w),
                  child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: CachedNetworkImage(
                        imageUrl: story.storyImageUrl,
                      )
                  )
              )
            ),
            SizedBox(width: 5.w,),
            SizedBox(
                height: 140.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 180.w,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: lockedString,
                              style: TextStyle(
                                color: Colors.red, // 👈 different color for lockedString
                                fontSize: 16.w,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: story.storyName,
                              style: TextStyle(
                                color: ConfigColor.textColorDefault,
                                fontSize: 16.w,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2,),
                    Row(
                        children: [
                          ChannelImage(story.channelImageUrl, story.channelName, 18.w, 12.w),
                          SizedBox(width: 2.w,),
                          SizedBox(
                            width: 145.w,
                            child: Marquee(
                                animationDuration: const Duration(seconds: 10),
                                directionMarguee: DirectionMarguee.oneDirection,
                                child: Text(
                                    story.channelName,
                                    style: TextStyle(
                                        color: ConfigColor.textColorDefault,
                                        fontSize: 12.w
                                    )
                                )
                            )
                          ),
                        ]
                    ),
                    const Spacer(),
                    SizedBox(
                        width: 180.w,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/home_page/favorite.svg",
                                width: 14.w,
                                height: 14.w,
                                fit: BoxFit.fitWidth,
                                color: DesignSystem.textColorGrey,
                              ),
                              SizedBox(width: 2.w,),
                              Text(
                                story.likesCount.toString(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: DesignSystem.textColorGrey,
                                ),
                              ),
                              SizedBox(width: 6.w,),
                              SvgPicture.asset(
                                "assets/icons/home_page/voice_chat.svg",
                                width: 14.w,
                                height: 14.w,
                                color: DesignSystem.textColorGrey,
                                fit: BoxFit.fitWidth,
                              ),
                              SizedBox(width: 3.w,),
                              Text(
                                story.voiceMessageCount.toString(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: DesignSystem.textColorGrey,
                                ),
                              )
                            ]
                        )
                    ),
                    SizedBox(height: 5.h,),
                    SizedBox(
                        width: 180.w,
                        child: Row(
                            children: [
                              Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.w),
                                      color: Colors.black26.withOpacity(0.05)
                                  ),
                                  padding: EdgeInsets.only(left: 7.w, top: 2.h, right: 7.w, bottom: 4.h), // for Mandarin
                                  child: Text(
                                    story.spaceName,
                                    textScaleFactor: 1 / MediaQuery.of(context).textScaleFactor,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                    ),
                                  )
                              ),
                              const Spacer(),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                      children: [
                                        Text(
                                          TimeUtils.dayAgo(story.storyUploadTime),
                                          style: TextStyle(
                                              fontSize: 12.w,
                                              color: ConfigColor.textColorDefault
                                          ),
                                        ),
                                      ]
                                  ),
                                  SizedBox(
                                      height: 18.h,
                                      child: VerticalDivider(
                                        color: Colors.black,
                                        thickness: 1.w,
                                        width: 10.w,
                                      )
                                  ),
                                  Text(
                                    TimeUtils.formatDuration(Duration(milliseconds: story.totalLength), " HH:mm:ss"),
                                    style: TextStyle(
                                        fontSize: 12.w,
                                        color: ConfigColor.textColorDefault
                                    ),
                                  ),
                                  const SizedBox(width: 4,),
                                  Container(
                                    padding: EdgeInsets.only(left: 2.w, right: 4.w),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.w),
                                      border: Border.all(color: DesignColor.primary50, width: 1),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
                                          child: PodCoin(size: 12.w),
                                        ),
                                        Text(
                                          story.price.toString(),
                                          style: TextStyle(
                                            fontSize: 10.w,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFFF9E1B), // orange text
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ]
                        )
                    )
                  ],
                )
            )
          ],
        ),
      ),
    );
  }
}

class _StoreTab extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _StoreTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 4,
              width: selected ? 120 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFFffbc1f),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final String svgPath;
  final VoidCallback? onTap;

  const _SocialIcon({
    required this.svgPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: SvgPicture.asset(
        svgPath,
        width: 24,
        height: 24,
      ),
    );
  }
}

class _ExclusiveLinkCard extends StatelessWidget {
  final PodcastStoreLinkDto item;

  const _ExclusiveLinkCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        LinkUtils.openLink(item.url);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 416,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: item.imageUrl.isNotEmpty
              ? DecorationImage(
            image: NetworkImage(item.imageUrl),
            fit: BoxFit.cover,
          ) : null,
        ),
      ),
    );
  }
}