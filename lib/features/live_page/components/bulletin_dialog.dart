import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/live_page/dto/bulletin.dart';
import 'package:actpod_web/utils/link_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

class BulletinDialog {
  Future<void> show(
      BuildContext context, {
        required List<RoomBulletinDto> bulletins,
      }) async {
    RoomBulletinDto? selectedBulletin;

    await showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDetail = selectedBulletin != null;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 520,
                      maxHeight: MediaQuery.of(context).size.height * 0.8,
                    ),
                    child: Dialog(
                      insetPadding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: isDetail
                            ? _BulletinDetailView(
                          key: const ValueKey('detail'),
                          bulletin: selectedBulletin!,
                          onBack: () {
                            setState(() {
                              selectedBulletin = null;
                            });
                          },
                          onClose: () {
                            Navigator.of(dialogContext).pop();
                          },
                        )
                            : _BulletinListView(
                          key: const ValueKey('list'),
                          bulletins: bulletins,
                          onTapBulletin: (bulletin) {
                            setState(() {
                              selectedBulletin = bulletin;
                            });
                          },
                          onClose: () {
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BulletinListView extends StatelessWidget {
  final List<RoomBulletinDto> bulletins;
  final ValueChanged<RoomBulletinDto> onTapBulletin;
  final VoidCallback onClose;

  const _BulletinListView({
    super.key,
    required this.bulletins,
    required this.onTapBulletin,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '公佈欄',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 30,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: bulletins.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  '目前沒有公告',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF777777),
                  ),
                ),
              ),
            )
                : ListView.separated(
              shrinkWrap: true,
              itemCount: bulletins.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final bulletin = bulletins[index];
                return _BulletinListItem(
                  bulletin: bulletin,
                  onTap: () => onTapBulletin(bulletin),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletinListItem extends StatelessWidget {
  final RoomBulletinDto bulletin;
  final VoidCallback onTap;

  const _BulletinListItem({
    required this.bulletin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Material(
      color: DesignColor.actpodPrimary50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                child: Icon(
                  Icons.alarm_on_rounded,
                  size: 20,
                  color: DesignColor.actpodPrimary400,
                )
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bulletin.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletinDetailView extends StatelessWidget {
  final RoomBulletinDto bulletin;
  final VoidCallback onBack;
  final VoidCallback onClose;

  const _BulletinDetailView({
    super.key,
    required this.bulletin,
    required this.onBack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = bulletin.imageUrl.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 22,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '公告內容',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 30,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        bulletin.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            height: 180,
                            color: const Color(0xFFEAEAEA),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              size: 36,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    bulletin.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: DesignColor.neutral600,
                    ),
                  ),
                  Linkify(
                    onOpen: LinkUtils.onOpenDescriptionLink,
                    options: const LinkifyOptions(humanize: false),
                    textAlign: TextAlign.start,
                    text: bulletin.content,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}