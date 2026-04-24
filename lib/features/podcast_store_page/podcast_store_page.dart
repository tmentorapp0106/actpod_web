import 'package:actpod_web/api_manager/channel_api_manager.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/podcast_store_page/dto/podcast_store.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:actpod_web/utils/link_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readmore/readmore.dart';

class PodcastStoreScreen extends StatefulWidget {
  final String userId;

  const PodcastStoreScreen({super.key, required this.userId});

  @override
  State<PodcastStoreScreen> createState() => _PodcastStoreScreenState();
}

class _PodcastStoreScreenState extends State<PodcastStoreScreen> {
  int selectedTabIndex = 1; // 0 = 付費Podcast, 1 = 專屬連結

  bool _isLoading = true;
  bool _loadFailed = false;
  PodcastStoreDto? _podcastStore;

  @override
  void initState() {
    super.initState();
    _loadPodcastStore();
  }

  Future<void> _loadPodcastStore() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final res = await channelApiManager.getPodcastStore(widget.userId);

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
            )
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
      itemCount: 0,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return const SizedBox.shrink();
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