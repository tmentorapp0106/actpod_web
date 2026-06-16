part of 'player_web_screen.dart';

class _WebDownloadCard extends StatelessWidget {
  const _WebDownloadCard();

  @override
  Widget build(BuildContext context) {
    return const _WebSideCard(
      child: Column(
        children: [
          Text(
            "下載 APP 收聽更多內容",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 12,
            children: [
              _WebStoreButton(
                imagePath: "assets/images/apple_download.png",
                url: "https://apps.apple.com/tw/app/actpod/id6468426325",
              ),
              _WebStoreButton(
                imagePath: "assets/images/google_download.png",
                url:
                    "https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW&pli=1",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WebStoreButton extends StatelessWidget {
  final String imagePath;
  final String url;

  const _WebStoreButton({
    required this.imagePath,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          debugPrint("Could not launch $url");
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Image.asset(
          imagePath,
          width: 128,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
