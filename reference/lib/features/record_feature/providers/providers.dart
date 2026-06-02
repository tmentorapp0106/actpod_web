import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/dto/draft_dto.dart';
import 'package:quick_share_app/dto/feed.dart';
import 'package:quick_share_app/dto/sync_setting.dart';

import '../../../dto/channel_dto.dart';
import '../../../dto/space_dto.dart';



final playerResetProvider = StateProvider.autoDispose<bool>((ref) => false);

final recordTimerProvider = StateProvider.autoDispose<Duration>((ref) => Duration.zero);

final recordStatusProvider = StateProvider.autoDispose<String>((ref) => "pending"); // pending, recording, pausing, finish

final uploadStatusProvider = StateProvider.autoDispose<bool>((ref) => false);

final waveformDataProvider = StateProvider.autoDispose<List<double>>((ref) => List.generate(100, (index) => 0.0));

final rssFeedProvider = StateProvider<List<RssFeed>?>((ref) => []);
final feedSelectionProvider =
NotifierProvider<FeedSelection, Set<String>>(() => FeedSelection());


// rss feed sync setting
class FeedSelection extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final feeds = ref.watch(rssFeedProvider) ?? const <RssFeed>[];
    // Default: select all current feeds
    return feeds.map((e) => e.guid).toSet();
  }

  void toggleOne(String guid) {
    final next = {...state};
    if (next.contains(guid)) {
      next.remove(guid);
    } else {
      next.add(guid);
    }
    state = next;
  }

  // Set all (true = select all, false = clear all)
  void setAll(bool select, List<RssFeed> feeds) {
    state = select ? feeds.map((e) => e.guid).toSet() : <String>{};
  }

  // Call this if feeds update and you want to keep user choices when possible
  void reconcileWith(List<RssFeed> feeds) {
    final available = feeds.map((e) => e.guid).toSet();
    // Keep only selections that still exist; new items are auto-selected
    final preserved = state.intersection(available);
    final newOnes = available.difference(preserved);
    state = {...preserved, ...newOnes};
  }
}
final spaceSelectionProvider = StateProvider<String?>((ref) => null);
final spaceListProvider = StateProvider<List<SpaceInfoDto>>((ref) => []);
final channelListProvider = StateProvider<List<ChannelDto>>((ref) => []);
final channelSelectionProvider = StateProvider<String?>((ref) => null);
final syncSettingProvider = StateProvider.autoDispose<SyncSettingDto?>((ref) => null);
final isRssFeedSynced = StateProvider.autoDispose<bool?>((ref) => null);
