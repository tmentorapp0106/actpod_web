import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:quick_share_app/router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../apiManagers/story_api_dto/get_one_story_res.dart';
import '../apiManagers/story_system_api_manager.dart';
import '../dto/player_item_dto.dart';

final String storyLink = "https://web.actpodapp.com/story/";

class LinkUtils {
  static Future<void> onOpenDescriptionLink(LinkableElement link) async {
    if(link.url.contains(storyLink)) {
      navigateToStory(link.url);
      return;
    }

    await launchUrl(
        Uri.parse(link.url),
        mode: LaunchMode.inAppBrowserView
    );
  }

  static Future<void> openLink(String link) async {
    await launchUrl(
        Uri.parse(link),
        mode: LaunchMode.inAppBrowserView
    );
  }

  static Future<void> onOpenDescriptionLinkString(String link) async {
    if(link.contains(storyLink)) {
      navigateToStory(link);
      return;
    }

    await launchUrl(
        Uri.parse(link),
        mode: LaunchMode.inAppBrowserView
    );
  }

  static Future<void> onOpenShortsVideoId(String videoId) async {
    await launchUrl(
      Uri.parse("https://youtube.com/shorts/$videoId"),
      mode: LaunchMode.inAppBrowserView
    );
  }

  static Future<void> navigateToStory(String url) async {
    String? storyId = _extractStoryId(url);
    if(storyId == null) {
      return;
    }
    GetOneStoryRes storyRes = await storyApiManager.getOneStory(storyId);
    if(storyRes.code != "0000") {
      return;
    }
    PlayerItemDto playItem = PlayerItemDto.fromGetOneStoryResItem(storyRes.story!);
    List<PlayerItemDto> playList = [playItem];
    router.push("/story/multiple", extra: {"playerItemList": playList, "index": 0});
  }

  static String? _extractStoryId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final seg = uri.pathSegments; // ["story", "123456"]
    final i = seg.indexOf('story');
    if (i == -1 || i + 1 >= seg.length) return null;

    return seg[i + 1]; // "123456"
  }
}