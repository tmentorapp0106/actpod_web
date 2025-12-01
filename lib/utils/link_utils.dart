import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkUtils {
  static Future<void> onOpenDescriptionLink(LinkableElement link) async {
    await launchUrl(
        Uri.parse(link.url),
        mode: LaunchMode.inAppBrowserView
    );
  }

  static Future<void> onOpenDescriptionLinkString(String link) async {
    await launchUrl(
        Uri.parse(link),
        mode: LaunchMode.inAppBrowserView
    );
  }
}