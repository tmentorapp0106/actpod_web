import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/record_feature/controllers/feed_controller.dart';
import 'package:quick_share_app/features/record_feature/providers/providers.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../../design_system/color.dart';
import '../../../../dto/feed.dart';

class RssFeedListView extends ConsumerWidget {
  final FeedController feedController;
  final String feed;

  const RssFeedListView({super.key, required this.feedController, required this.feed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feeds = ref.watch(rssFeedProvider);
    final selected = ref.watch(feedSelectionProvider);

    if(feeds == null) {
      return Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.only(top: 12.h),
          child: const CircularProgressIndicator(
            color: DesignColor.primary50,
          ),
        ),
      );
    }

    // Keep selection in sync when feeds change (preserve user choices)
    ref.listen<List<RssFeed>?>(rssFeedProvider, (prev, next) {
      if (next != null) {
        ref.read(feedSelectionProvider.notifier).reconcileWith(next);
      }
    });

    final allGuids = feeds.map((e) => e.guid).toSet();
    final selectedCount = selected.intersection(allGuids).length;
    final total = allGuids.length;

    bool? selectAllValue;
    if (total == 0) {
      selectAllValue = false;
    } else if (selectedCount == 0) {
      selectAllValue = false;
    } else if (selectedCount == total) {
      selectAllValue = true;
    } else {
      selectAllValue = null; // indeterminate
    }

    return Expanded(
      child: Column(
        children: [
          // ---- Select All row (tri-state) ----
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              tristate: true,
              activeColor: DesignColor.primary50,
              value: selectAllValue,
              onChanged: (v) {
                final notifier = ref.read(feedSelectionProvider.notifier);
                if (v == false) {
                  // User unticked "全選" -> clear everything
                  notifier.setAll(false, feeds);
                } else if (v == true) {
                  // v == true or v == null (indeterminate tap) -> select all
                  notifier.setAll(true, feeds);
                } else {
                  notifier.setAll(false, feeds);
                }
              },
              title: Text(
                "全選"
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),

          const Divider(height: 0),

          // ---- List of episodes with a checkbox per item ----
          Expanded(
            child: ListView.separated(
              itemCount: feeds.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final f = feeds[index];
                final checked = selected.contains(f.guid);

                return CheckboxListTile(
                  value: checked,
                  onChanged: (_) {
                    ref.read(feedSelectionProvider.notifier).toggleOne(f.guid);
                  },
                  activeColor: DesignColor.primary50,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  // Leading image (optional)
                  secondary: (f.imageUrl.isNotEmpty)
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      f.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                      : null,
                  title: Text(
                    f.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: (f.desc.isNotEmpty)
                      ? Text(
                    f.desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                      : null,
                );
              },
            ),
          ),

          // ---- Example action bar using the selection ----
          if (total > 0)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: DesignColor.white,
                          backgroundColor: DesignColor.primary50,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.w),
                          minimumSize: const Size(0, 0),                 // allow smaller than default
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // shrink touch target
                          visualDensity: VisualDensity.compact,           // less outer space
                        ),
                        onPressed: () async {
                          final chosenGuids = feeds
                              .where((f) => selected.contains(f.guid))
                              .map((f) => f.guid)
                              .toList();
                          if(ref.watch(spaceSelectionProvider) == null || ref.watch(spaceSelectionProvider)!.isEmpty) {
                            ToastService.showNoticeToast("請選擇同步空間");
                            return;
                          }
                          if(ref.watch(spaceSelectionProvider) == null || ref.watch(spaceSelectionProvider)!.isEmpty) {
                            ToastService.showNoticeToast("請選擇同步頻道");
                            return;
                          }
                          final spaceId = ref.watch(spaceListProvider).firstWhere((space) => space.name == ref.watch(spaceSelectionProvider)).spaceId;
                          final channelId = ref.watch(channelListProvider).firstWhere((channel) => channel.channelName == ref.watch(channelSelectionProvider)).channelId;
                          ref.watch(loadingProvider.notifier).state = true;
                          await feedController.bindFeed(feed, chosenGuids, channelId, spaceId);
                          ref.watch(loadingProvider.notifier).state = false;
                          if(context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                        child: const Text(
                          '同步並綁定',
                          style: TextStyle(
                            color: Colors.black
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      )
    );
  }
}