import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/exist_sync_setting_res.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/get_sync_setting_res.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/manual_sync_res.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/remove_sync_setting_res.dart';
import 'package:quick_share_app/apiManagers/sync_api_dto/update_sync_setting_res.dart';
import 'package:quick_share_app/apiManagers/sync_system_api_manager.dart';
import 'package:quick_share_app/dto/feed.dart';
import 'package:http/http.dart' as http;
import 'package:quick_share_app/features/record_feature/providers/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:xml/xml.dart';

import '../../../apiManagers/sync_api_dto/first_sync_res.dart';

class FeedController {
  WidgetRef ref;
  FeedController(this.ref);

  Future<void> isSynced() async {
    ExistSyncSettingRes response = await syncApiManager.existSyncSetting();
    if(response.code != "0000") {
      return;
    }
    ref.watch(isRssFeedSynced.notifier).state = response.data;
  }

  Future<void> getSyncSetting() async {
    GetSyncSettingRes response = await syncApiManager.getSyncSetting();
    if(response.code != "0000") {
      return;
    }
    ref.watch(syncSettingProvider.notifier).state = response.syncSetting;
    ref.watch(channelSelectionProvider.notifier).state = response.syncSetting?.channelName;
    ref.watch(spaceSelectionProvider.notifier).state = response.syncSetting?.spaceName;
  }

  Future<void> updateSyncSetting(String channelId, String spaceId) async {
    UpdateSyncSettingRes response = await syncApiManager.updateSyncSetting(channelId, spaceId);
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    ToastService.showSuccessToast("更新成功");
  }

  Future<void> removeSyncSetting() async {
    RemoveSyncSettingRes response = await syncApiManager.removeSyncSetting();
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    ToastService.showSuccessToast("解綁成功");
  }

  Future<void> bindFeed(String feed, List<String> guids, String channelId, String spaceId) async {
    FirstSyncRes response = await syncApiManager.firstSync(feed, guids, channelId, spaceId);
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    ToastService.showSuccessToast("綁定成功");
  }

  Future<void> manualSync() async {
    ManualSyncRes response = await syncApiManager.manualSync();
    if(response.code != "0000") {
      ToastService.showNoticeToast(response.message);
      return;
    }
    ToastService.showSuccessToast("成功送出同步請求");
  }

  Future<void> fetchPodcastRss(String rssUrl) async {
    ref.watch(rssFeedProvider.notifier).state = null;
    http.Response response;
    try {
      response = await http.get(Uri.parse(rssUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load RSS feed');
      }
    } catch (e) {
      ToastService.showNoticeToast("找不到內容");
      ref.watch(rssFeedProvider.notifier).state = [];
      return;
    }

    final decoded = utf8.decode(response.bodyBytes); // correct character decoding
    final document = XmlDocument.parse(decoded);

    // Channel-level image (fallback for items)
    final channel = document.findAllElements('channel').first;
    String? imageUrl;
    final itunesImage = channel.findElements('itunes:image');
    if (itunesImage.isNotEmpty) {
      imageUrl = itunesImage.first.getAttribute('href');
    } else {
      final imageTag = channel.findElements('image');
      if (imageTag.isNotEmpty) {
        final urlEl = imageTag.first.findElements('url');
        if (urlEl.isNotEmpty) imageUrl = urlEl.first.text;
      }
    }

    final items = document.findAllElements('item');

    final feeds = items.map((item) {
      final title = _firstText(item, ['title']) ?? '';
      final enclosure = item.findElements('enclosure').isNotEmpty
          ? item.findElements('enclosure').first
          : null;
      final audioUrl = enclosure?.getAttribute('url') ?? '';

      // Prefer richer/longer fields first
      final rawDescription = _firstText(item, [
        'content:encoded',
        'itunes:summary',
        'description',
        'summary',
      ]) ??
          '';

      // If your UI expects plain text, strip tags; otherwise keep rawDescription.
      final description = _stripHtml(rawDescription).trim();

      // Some feeds provide per-episode image; use it if present, fall back to channel image
      String episodeImage = _firstAttr(item, [
        ['itunes:image', 'href'],
      ]) ??
          imageUrl ??
          '';

      final guidEl = item.getElement('guid');
      final guidText = guidEl?.innerText.trim() ?? '';

      // Fallbacks for feeds that omit <guid> (rare but happens)
      final linkText = _firstText(item, ['link']) ?? '';
      final pubDate = _firstText(item, ['pubDate']) ?? '';
      final stableGuid = (guidText.isNotEmpty)
          ? guidText
          : (audioUrl.isNotEmpty ? audioUrl : (linkText.isNotEmpty ? '$linkText#$pubDate' : title));

      return RssFeed(
        title: title,
        audioUrl: audioUrl,
        imageUrl: episodeImage,
        desc: description,
        guid: stableGuid
      );
    }).toList();

    if (feeds.isEmpty) {
      ref.watch(rssFeedProvider.notifier).state = [];
      throw Exception('No valid podcast episodes found in the RSS feed');
    }

    ref.watch(rssFeedProvider.notifier).state = feeds;
  }

  /// Finds the first non-empty text content among a list of candidate tags.
  String? _firstText(XmlElement parent, List<String> tags) {
    for (final t in tags) {
      final els = parent.findElements(t);
      if (els.isNotEmpty) {
        final text = els.first.text.trim();
        if (text.isNotEmpty) return text;
      }
    }
    return null;
  }

  /// Finds the first present attribute among (tag, attr) candidates.
  String? _firstAttr(XmlElement parent, List<List<String>> tagAttrPairs) {
    for (final pair in tagAttrPairs) {
      final tag = pair[0], attr = pair[1];
      final els = parent.findElements(tag);
      if (els.isNotEmpty) {
        final v = els.first.getAttribute(attr);
        if (v != null && v.trim().isNotEmpty) return v.trim();
      }
    }
    return null;
  }

  /// Very simple HTML tag stripper. Remove if you want to keep HTML formatting.
  String _stripHtml(String input) {
    final withoutTags = input.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode a few common HTML entities manually if needed
    return withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
}