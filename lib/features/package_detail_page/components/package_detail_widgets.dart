import 'dart:typed_data';

import 'package:actpod_web/api_manager/purchase_dto/create_credit_card_payment.dart';
import 'package:actpod_web/api_manager/purchase_system_api_manager.dart';
import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/podcoin.dart';
import 'package:actpod_web/dto/package_dto.dart';
import 'package:actpod_web/features/explore_page/providers.dart'
    as explore_providers;
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/package_detail_page/controllers/package_detail_controller.dart';
import 'package:actpod_web/features/package_detail_page/providers.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:actpod_web/services/toast_service.dart';
import 'package:actpod_web/utils/link_utils.dart';
import 'package:actpod_web/utils/neweb_pay_form.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const packageAccent = Color(0xFFFFA300);
const packageSoft = Color(0xFFFFFAEF);
const packageBorder = Color(0xFFFFD78A);
const _googlePlayUrl =
    "https://play.google.com/store/apps/details?id=com.sharevoice&hl=zh_TW";
const _appStoreUrl = "https://apps.apple.com/tw/app/actpod/id6468426325";

class PackageCover extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double badgeSize;

  const PackageCover({
    super.key,
    required this.imageUrl,
    required this.height,
    this.badgeSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: height,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFFFF1CF),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: packageAccent,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 16,
            top: 14,
            child: PackageBadge(fontSize: badgeSize),
          ),
        ],
      ),
    );
  }
}

class PackageBadge extends StatelessWidget {
  final double fontSize;

  const PackageBadge({
    super.key,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.65,
        vertical: fontSize * 0.38,
      ),
      decoration: BoxDecoration(
        color: packageAccent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "套裝",
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          height: 1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class PackageInfoCard extends ConsumerWidget {
  final PackageInfoWithStoriesItem package;
  final bool compact;
  final PackageDetailController packageDetailController;

  const PackageInfoCard({
    super.key,
    required this.package,
    required this.packageDetailController,
    this.compact = false,
  });

  Future<void> _handlePurchase(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!AuthService.isLoggedIn()) {
      final bool? loggedIn = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const LoginScreen();
        },
      );

      if (loggedIn != true || !context.mounted) {
        return;
      }

      await packageDetailController.checkPurchased(package.packageId);
      return;
    }

    final invoiceEmail = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return InvoiceEmailDialog(
          initialEmail: UserPrefs.getUserInfo()?.email ?? "",
        );
      },
    );

    if (invoiceEmail == null) {
      return;
    }

    CreateCreditCardPaymentRes response =
        await purchaseApiManager.createCreditCardPayment(
      package.packagePrice!.twd,
      "package",
      package.packageId,
      package.packageName,
      invoiceEmail,
    );
    if (response.code != "0000") {
      return;
    }
    submitNewebPayForm(
      gatewayUrl: response.creditCardPayment!.gatewayURL,
      merchantID: response.creditCardPayment!.merchantID,
      tradeInfo: response.creditCardPayment!.tradeInfo,
      tradeSha: response.creditCardPayment!.tradeSha,
      version: response.creditCardPayment!.version,
    );
  }

  void _handleStartListening(BuildContext context) {
    final firstStory = package.stories.first;
    if (firstStory.storyUrl.trim().isEmpty) {
      ToastService.showNoticeToast("尚未上傳內容");
      return;
    }

    context.push("/story/${firstStory.storyId}");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final twd = package.packagePrice?.twd;
    final purchased = ref.watch(packagePurchasedProvider);
    final isLoggedIn = AuthService.isLoggedIn();
    final isNotForSale = twd == null || twd < 0;
    final isPurchaseLoading = purchased == null;
    final canPurchase = !isNotForSale && purchased == false;
    final canStartListening = purchased == true && package.stories.isNotEmpty;
    final priceText = isNotForSale ? "--" : twd.toString();
    final buttonText = purchased == true
        ? package.stories.isEmpty
            ? "目前沒有單集"
            : "開始收聽第一集"
        : isNotForSale
            ? "尚未開賣"
            : isLoggedIn
                ? "購買套裝"
                : "前往購買";

    return Container(
      padding: EdgeInsets.all(compact ? 14 : 24),
      decoration: BoxDecoration(
        color: packageSoft,
        borderRadius: BorderRadius.circular(compact ? 10 : 14),
        border: Border.all(color: packageBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            const PackageBadge(),
            const SizedBox(height: 14),
          ],
          Text(
            package.packageName,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 22 : 28,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Avatar(package.userId, package.avatarUrl, compact ? 15 : 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  package.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (purchased != true) ...[
            SizedBox(height: compact ? 16 : 24),
            const Text(
              "套裝價",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceText,
                  style: TextStyle(
                    color: packageAccent,
                    fontSize: compact ? 38 : 58,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: EdgeInsets.only(bottom: compact ? 6 : 10),
                  child: const Text(
                    "台幣",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          PackagePrimaryButton(
            text: buttonText,
            loading: !isNotForSale && isPurchaseLoading,
            onPressed: canStartListening
                ? () => _handleStartListening(context)
                : canPurchase
                    ? () => _handlePurchase(context, ref)
                    : null,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class InvoiceEmailDialog extends StatefulWidget {
  final String initialEmail;

  const InvoiceEmailDialog({
    super.key,
    required this.initialEmail,
  });

  @override
  State<InvoiceEmailDialog> createState() => _InvoiceEmailDialogState();
}

class _InvoiceEmailDialogState extends State<InvoiceEmailDialog> {
  late final TextEditingController _emailController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  void _confirm() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorText = "請輸入電子發票收件 Email";
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _errorText = "請輸入有效的 Email";
      });
      return;
    }

    Navigator.of(context).pop(email);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        "確認電子發票 Email",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "電子發票將寄送到以下 Email，您可以在付款前修改。",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
              onSubmitted: (_) => _confirm(),
              decoration: InputDecoration(
                labelText: "Email",
                errorText: _errorText,
                filled: true,
                fillColor: const Color(0xFFFFFAEF),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: packageBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: packageAccent,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black87,
          ),
          child: const Text(
            "取消",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: packageAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: const Text(
            "確認付款",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class PackagePrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  const PackagePrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? const Color(0xFFD8D8D8) : packageAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFD8D8D8),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class PackageOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PackageOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: const BorderSide(color: Color(0xFF7D7D7D)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class PackageTags extends StatelessWidget {
  final PackageInfoItem package;

  const PackageTags({
    super.key,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    final tags = [];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => PackageTag(text: tag)).toList(),
    );
  }
}

class PackageTag extends StatelessWidget {
  final String text;

  const PackageTag({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF4F4F4F),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class PackageDescriptionSection extends StatelessWidget {
  final PackageInfoWithStoriesItem package;

  const PackageDescriptionSection({
    super.key,
    required this.package,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "套裝介紹"),
        const SizedBox(height: 10),
        PackageDescriptionContent(
          description:
              package.packageDescription,
        ),
        // const SizedBox(height: 14),
        // PackageTags(package: package),
      ],
    );
  }
}

class PackageDescriptionContent extends StatelessWidget {
  final String description;

  const PackageDescriptionContent({
    super.key,
    required this.description,
  });

  static final RegExp _urlRegex = RegExp(r'https?:\/\/[^\s<>()]+');

  TextStyle get _descriptionStyle => const TextStyle(
        fontSize: 16,
        height: 1.7,
        fontWeight: FontWeight.w600,
      );

  @override
  Widget build(BuildContext context) {
    final segments = _descriptionSegments(description);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((segment) {
        if (segment.isUrl) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: DescriptionImageOrLink(url: segment.value),
          );
        }

        return Text(
          segment.value,
          style: _descriptionStyle,
        );
      }).toList(),
    );
  }

  List<_DescriptionSegment> _descriptionSegments(String value) {
    final segments = <_DescriptionSegment>[];
    var start = 0;

    for (final match in _urlRegex.allMatches(value)) {
      final rawUrl = value.substring(match.start, match.end);
      final url = _trimTrailingUrlPunctuation(rawUrl);
      final trailing = rawUrl.substring(url.length);

      if (match.start > start) {
        segments
            .add(_DescriptionSegment.text(value.substring(start, match.start)));
      }

      segments.add(_DescriptionSegment.url(url));

      if (trailing.isNotEmpty) {
        segments.add(_DescriptionSegment.text(trailing));
      }

      start = match.end;
    }

    if (start < value.length) {
      segments.add(_DescriptionSegment.text(value.substring(start)));
    }

    return segments.where((segment) => segment.value.isNotEmpty).toList();
  }

  String _trimTrailingUrlPunctuation(String value) {
    return value.replaceFirst(RegExp(r'[,.!?;:，。！？；：]+$'), '');
  }
}

class DescriptionImageOrLink extends StatefulWidget {
  final String url;

  const DescriptionImageOrLink({
    super.key,
    required this.url,
  });

  @override
  State<DescriptionImageOrLink> createState() => _DescriptionImageOrLinkState();
}

class _DescriptionImageOrLinkState extends State<DescriptionImageOrLink> {
  late final Future<Uint8List?> _imageBytesFuture;

  @override
  void initState() {
    super.initState();
    _imageBytesFuture = _loadImageBytesIfImage(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldCheckAsImageUrl(widget.url)) {
      return DescriptionUrlLink(url: widget.url);
    }

    return FutureBuilder<Uint8List?>(
      future: _imageBytesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            width: double.infinity,
            height: 160,
            color: const Color(0xFFF4F4F4),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final imageBytes = snapshot.data;
        if (imageBytes == null) {
          return DescriptionUrlLink(url: widget.url);
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            imageBytes,
            errorBuilder: (context, error, stackTrace) {
              return DescriptionUrlLink(url: widget.url);
            },
          ),
        );
      },
    );
  }

  bool _shouldCheckAsImageUrl(String value) {
    final uri = Uri.tryParse(value);

    if (uri == null || !uri.hasAbsolutePath) {
      return false;
    }

    final path = uri.path.toLowerCase();
    final lastSegment = uri.pathSegments.isEmpty ? "" : uri.pathSegments.last;
    final hasFileExtension = lastSegment.contains(".");

    if (path.contains("/image/")) {
      return true;
    }

    if (!hasFileExtension) {
      return true;
    }

    return RegExp(r'\.(png|jpe?g|gif|webp|bmp|avif)$').hasMatch(path);
  }

  Future<Uint8List?> _loadImageBytesIfImage(String url) async {
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data ?? const []);

      if (_isImageBytes(bytes)) {
        return bytes;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  bool _isImageBytes(Uint8List bytes) {
    if (bytes.length < 12) {
      return false;
    }

    final isJpeg = bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
    final isPng = bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A;
    final isGif = bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x38;
    final isWebp =
        _matchesAscii(bytes, 0, "RIFF") && _matchesAscii(bytes, 8, "WEBP");
    final isBmp = bytes[0] == 0x42 && bytes[1] == 0x4D;
    final isAvif = _matchesAscii(bytes, 4, "ftyp") &&
        (_matchesAscii(bytes, 8, "avif") || _matchesAscii(bytes, 8, "avis"));

    return isJpeg || isPng || isGif || isWebp || isBmp || isAvif;
  }

  bool _matchesAscii(Uint8List bytes, int offset, String value) {
    if (bytes.length < offset + value.length) {
      return false;
    }

    for (var i = 0; i < value.length; i++) {
      if (bytes[offset + i] != value.codeUnitAt(i)) {
        return false;
      }
    }

    return true;
  }
}

class DescriptionUrlLink extends StatelessWidget {
  final String url;

  const DescriptionUrlLink({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => LinkUtils.onOpenDescriptionLinkString(url),
      child: Text(
        url,
        style: const TextStyle(
          color: packageAccent,
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationColor: packageAccent,
        ),
      ),
    );
  }
}

class _DescriptionSegment {
  final String value;
  final bool isUrl;

  const _DescriptionSegment._({
    required this.value,
    required this.isUrl,
  });

  factory _DescriptionSegment.text(String value) {
    return _DescriptionSegment._(value: value, isUrl: false);
  }

  factory _DescriptionSegment.url(String value) {
    return _DescriptionSegment._(value: value, isUrl: true);
  }
}

class PackageStoriesSection extends ConsumerWidget {
  final PackageInfoWithStoriesItem package;
  final bool compact;

  const PackageStoriesSection({
    super.key,
    required this.package,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchased = ref.watch(packagePurchasedProvider) == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Color(0xFFE6E6E6), height: 32),
        const SectionTitle(title: "內容單集"),
        const SizedBox(height: 10),
        if (package.stories.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                "目前沒有單集",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        else
          ...package.stories.map(
            (story) => PackageStoryRow(
              story: story,
              purchased: purchased,
              compact: compact,
            ),
          ),
      ],
    );
  }
}

class PackageStoryRow extends StatelessWidget {
  final StoryInfoItem story;
  final bool purchased;
  final bool compact;

  const PackageStoryRow({
    super.key,
    required this.story,
    required this.purchased,
    this.compact = false,
  });

  Future<void> _showNotPurchasedAlert(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "尚未購買",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            "請先購買套裝後再收聽此單集。",
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "確認",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleTap(BuildContext context) {
    if (!purchased) {
      _showNotPurchasedAlert(context);
      return;
    }

    if (story.storyUrl.trim().isEmpty) {
      ToastService.showNoticeToast("尚未上傳內容");
      return;
    }

    context.push("/story/${story.storyId}");
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = story.storyImageUrls.isNotEmpty
        ? story.storyImageUrls.first
        : story.channelImageUrl;
    final packageNote = story.packageNote.trim();

    return InkWell(
      onTap: () => _handleTap(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: compact ? 6 : 10, horizontal: 8),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEAEAEA)),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                imageUrl,
                width: compact ? 64 : 112,
                height: compact ? 48 : 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: compact ? 64 : 112,
                    height: compact ? 48 : 64,
                    color: const Color(0xFFF2F2F2),
                    child: const Icon(Icons.podcasts, color: Colors.grey),
                  );
                },
              ),
            ),
            SizedBox(width: compact ? 8 : 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.storyName,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 12 : 17,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    story.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 10 : 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (packageNote.isNotEmpty) ...[
                    SizedBox(height: compact ? 4 : 6),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 6 : 8,
                        vertical: compact ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        packageNote,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 10 : 13,
                          height: 1.35,
                          color: const Color(0xFF6B4B12),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: compact ? 10 : 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        TimeUtils.formatDuration(
                          Duration(seconds: story.storyLength),
                          "HH:mm:ss",
                        ),
                        style: TextStyle(
                          fontSize: compact ? 9 : 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: compact ? 8 : 14),
            if (!purchased)
              Icon(
                Icons.lock_outline,
                color: Colors.grey,
                size: compact ? 22 : 32,
              )
            else
              Container(
                width: compact ? 26 : 42,
                height: compact ? 26 : 42,
                decoration: const BoxDecoration(
                  color: packageAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: compact ? 18 : 28,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PodCoinSummaryCard extends ConsumerWidget {
  final bool compact;
  final PackageDetailController packageDetailController;
  final String packageId;

  const PodCoinSummaryCard(
      {super.key,
      this.compact = false,
      required this.packageDetailController,
      required this.packageId});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("確認登出"),
          content: const Text("確定要登出 ActPod 嗎？"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("登出"),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await AuthService.logout();
    ref.read(userInfoProvider.notifier).state = null;
    ref.read(userPodCoinsProvider.notifier).state = 0;
    ref.read(packagePurchasedProvider.notifier).state = false;
    ref.read(explore_providers.purchasedStoriesProvider.notifier).state = [];
  }

  Future<void> _showEditDownloadDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "請下載 ActPod 編輯",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StoreDownloadButton(
                imagePath: "assets/images/google_download.png",
                onPressed: () {
                  Navigator.of(context).pop();
                  LinkUtils.openLink(_googlePlayUrl);
                },
              ),
              const SizedBox(height: 10),
              _StoreDownloadButton(
                imagePath: "assets/images/apple_download.png",
                onPressed: () {
                  Navigator.of(context).pop();
                  LinkUtils.openLink(_appStoreUrl);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userInfoProvider);
    final podCoins = ref.watch(userPodCoinsProvider);
    final userDescription = user?.selfDescription.trim() ?? "";

    if (user == null) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 18 : 22,
          vertical: compact ? 14 : 18,
        ),
        decoration: BoxDecoration(
          color: packageSoft,
          borderRadius: BorderRadius.circular(compact ? 10 : 14),
          border: Border.all(color: packageBorder),
        ),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: compact ? 36 : 44,
            child: ElevatedButton.icon(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return const LoginScreen();
                  },
                );
                await packageDetailController.checkPurchased(packageId);
              },
              icon: Icon(Icons.login, size: compact ? 18 : 20),
              label: Text(
                "登入",
                style: TextStyle(
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: packageAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 22),
      decoration: BoxDecoration(
        color: packageSoft,
        borderRadius: BorderRadius.circular(compact ? 10 : 14),
        border: Border.all(color: packageBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(user.userId, user.avatarUrl, compact ? 24 : 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user.nickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 15 : 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (userDescription.isNotEmpty) ...[
            SizedBox(height: compact ? 4 : 8),
            Text(
              userDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF5F5F5F),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          SizedBox(height: compact ? 8 : 12),
          Text(
            compact ? "剩餘的 PodCoin" : "剩餘的 PodCoin:",
            style: TextStyle(
              color: compact ? Colors.black87 : null,
              fontSize: compact ? 14 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: compact ? 2 : 0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                podCoins.toString(),
                style: TextStyle(
                  fontSize: compact ? 28 : 34,
                  height: 1,
                  fontWeight: compact ? FontWeight.w900 : FontWeight.w800,
                  letterSpacing: compact ? 1 : 0,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(bottom: compact ? 8 : 10),
                child: Text(
                  "PodCoin",
                  style: TextStyle(
                    fontSize: compact ? 15 : 14,
                    fontWeight: compact ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              PodCoin(size: compact ? 36 : 42),
            ],
          ),
          SizedBox(height: compact ? 8 : 18),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton.icon(
              onPressed: () {
                _showEditDownloadDialog(context);
              },
              icon: Icon(Icons.edit, size: compact ? 18 : 20),
              label: Text(
                "編輯資訊",
                style: TextStyle(
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: packageAccent,
                side: const BorderSide(color: packageAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 8 : 10),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: Icon(Icons.logout, size: compact ? 18 : 20),
              label: Text(
                "登出",
                style: TextStyle(
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8F8F8F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreDownloadButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const _StoreDownloadButton({
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 34,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class PackageDetailLoading extends StatelessWidget {
  const PackageDetailLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: Center(
        child: CircularProgressIndicator(
          color: packageAccent,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class PackageDetailError extends StatelessWidget {
  final String? message;

  const PackageDetailError({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: packageAccent,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                message?.isNotEmpty == true ? message! : "找不到套裝資訊",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.go("/explore"),
                child: const Text("回探索頁"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
