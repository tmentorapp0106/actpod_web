import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _appStoreUrl = "https://apps.apple.com/tw/app/actpod/id6468426325";
const _googlePlayUrl =
    "https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW";

class ActPodDownloadWidget extends StatelessWidget {
  final bool compact;

  const ActPodDownloadWidget({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 18 : 28,
        vertical: compact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        border: Border.all(color: const Color(0xFFEDEDED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: compact ? 0.04 : 0.05),
            blurRadius: compact ? 16 : 24,
            offset: Offset(0, compact ? 6 : 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            "assets/images/actpod_logo_web.png",
            height: compact ? 32 : 36,
            fit: BoxFit.fitHeight,
          ),
          SizedBox(height: compact ? 8 : 8),
          Text(
            "下載 ActPod app",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 18 : 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: compact ? 6 : 8),
          Text(
            "用手機購買套裝、收聽故事，隨時接續你的聲音旅程",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF666666),
              fontSize: compact ? 14 : 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: compact ? 12 : 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: compact ? 8 : 12,
            runSpacing: 10,
            children: const [
              _StoreBadgeButton(
                imagePath: "assets/images/apple_download.png",
                url: _appStoreUrl,
              ),
              _StoreBadgeButton(
                imagePath: "assets/images/google_download.png",
                url: _googlePlayUrl,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoreBadgeButton extends StatelessWidget {
  final String imagePath;
  final String url;

  const _StoreBadgeButton({
    required this.imagePath,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint("Could not launch $url");
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Image.asset(
          imagePath,
          width: 138,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
