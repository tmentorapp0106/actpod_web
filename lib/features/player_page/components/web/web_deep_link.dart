part of 'player_web_screen.dart';

Future<void> _openStoryDeepLink(BuildContext context, String storyId) async {
  final bool? goto = await showDialog<bool>(
    context: context,
    builder: (context) => LaunchDeepLinkDialog(),
  );

  if (goto != true) {
    return;
  }

  await Future.delayed(const Duration(microseconds: 500));
  await _launchStoryExternal(storyId);
}

Future<void> _launchStoryExternal(String storyId) async {
  final url =
      "https://actpod-488af.web.app/story/link/$storyId?openExternalBrowser=1";
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    debugPrint("Could not launch $url");
  }
}
