import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/dto/feed.dart';
import 'package:quick_share_app/features/record_feature/controllers/feed_controller.dart';
import 'package:quick_share_app/features/record_feature/providers/providers.dart';
import 'package:quick_share_app/features/record_feature/screens/sync_setting_screen.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../screens/rss_sync_screen.dart';

class FeedListBottomModel extends ConsumerStatefulWidget {
  final FeedController feedController;
  const FeedListBottomModel(this.feedController, {super.key});

  @override
  ConsumerState<FeedListBottomModel> createState() => _FeedListBottomModelState();
}

class _FeedListBottomModelState extends ConsumerState<FeedListBottomModel> {
  late final TextEditingController rssController;

  @override
  void initState() {
    super.initState();
    rssController = TextEditingController();
  }

  @override
  void dispose() {
    rssController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final episodes = ref.watch(rssFeedProvider);
    final isSynced = ref.watch(isRssFeedSynced);

    Widget syncSetting;
    if (isSynced == null) {
      syncSetting = const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          color: Colors.black,
          strokeWidth: 2,
        ),
      );
    } else if (isSynced) {
      syncSetting = const Text(
        '綁定設定',
        style: TextStyle(fontSize: 18, color: Colors.black),
      );
    } else {
      syncSetting = const Text(
        '前往綁定',
        style: TextStyle(fontSize: 18, color: Colors.black),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent, // lets taps pass through to children
      onTap: () => FocusScope.of(context).unfocus(),
      child:ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: rssController,
                            decoration: InputDecoration(
                              hintText: '輸入 RSS feed 連結',
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: ConfigColor.primaryDefault,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: ConfigColor.primaryDefault,
                                ),
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 12.w),
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () async {
                            try {
                              await widget.feedController
                                  .fetchPodcastRss(rssController.text);
                            } catch (e) {
                              ref.read(rssFeedProvider.notifier).state = [];
                              ToastService.showNoticeToast("找不到內容");
                            }
                          },
                          child: const Text(
                            '搜尋',
                            style: TextStyle(
                              fontSize: 16,
                              color: ConfigColor.primaryDefault,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: episodes == null
                        ? Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: EdgeInsets.only(top: 12.h),
                        child: const CircularProgressIndicator(
                          color: DesignColor.primary50,
                        ),
                      ),
                    )
                        : ListView.builder(
                      itemCount: episodes.length,
                      itemBuilder: (context, index) {
                        final episode = episodes[index];
                        return _buildEpisodeTile(context, episode);
                      },
                    ),
                  ),
                  SizedBox(height: 48.h),
                ],
              ),
              Positioned(
                bottom: 24.h,
                left: 0,
                right: 0,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (isSynced != null && isSynced) {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => SyncSettingScreen(),
                          ),
                        );
                        if (updated == true && mounted) {
                          Navigator.of(context).pop();
                        }
                        return;
                      }

                      if (rssController.text.isEmpty) {
                        ToastService.showNoticeToast("請輸入 rss feed");
                        return;
                      }

                      if (isSynced == null) {
                        return;
                      } else if (isSynced) {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => SyncSettingScreen(),
                          ),
                        );
                        if (updated == true && mounted) {
                          Navigator.of(context).pop();
                        }
                      } else {
                        final send = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) =>
                                RssSyncScreen(feed: rssController.text),
                          ),
                        );
                        if (send == true && mounted) {
                          ref.read(rssFeedProvider.notifier).state = [];
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: DesignColor.white,
                      backgroundColor: DesignColor.primary50,
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 16.w),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: syncSetting,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildEpisodeTile(BuildContext context, RssFeed episode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).pop(episode);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    episode.imageUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.podcasts),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    episode.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}