import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';

import 'dto/player_item_dto.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('zh', 'TW'));
final mainPageIndexProvider = StateProvider<int>((ref) => 0);
final loadingProvider = StateProvider<bool>((ref) => false);
final loadingTextProvider = StateProvider<String?>((ref) => null);
final loadingPercentageProvider = StateProvider<int?>((ref) => null);

final userPodCoinsProvider = StateProvider<int>((ref) => 0);
final userPodCashProvider = StateProvider<int>((ref) => 0);
final podCoinsListProvider = StateProvider<List<Offering>>((ref) => []);
final selectPodcoinProvider = StateProvider.autoDispose<Offering?>((ref) => null);

final loadingPlayerStoryInfoProvider = StateProvider<PlayerItemDto?>((ref) => null);
final mainPlayerStoryInfoProvider = StateProvider<PlayerItemDto?>((ref) => null);
final mainPlayerItemListProvider = StateProvider<List<PlayerItemDto>>((ref) => []);
enum MainPlayerState {
  initiating,
  loading,
  paused,
  playing,
}
final mainPlayerStatusProvider = StateProvider<MainPlayerState>((ref) => MainPlayerState.paused);
final mainPlayerPositionProvider =  StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final mainPlayerLengthProvider = StateProvider<Duration>((ref) => Duration.zero);
final mainPlayerBufferPositionProvider =  StateProvider.autoDispose<Duration>((ref) => Duration.zero);
final isPlayingInteractiveContentProvider = StateProvider<bool>((ref) => false);

final currentPreviewPageProvider = StateProvider<PreviewPage>((ref) => PreviewPage.none);
enum PreviewPage {
  none,
  home,
  space,
  channel
}
final previewPlayIndexProvider = StateProvider.autoDispose<int?>((ref) => null);
final previewPlayStatusProvider = StateProvider<PreviewPlayStatus>((ref) => PreviewPlayStatus.paused);
enum PreviewPlayStatus {
  loading,
  playing,
  paused,
}

final homePageScrollController = ScrollController();