import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:quick_share_app/design_system/color.dart';

import '../../../../../dto/room_bulletin_dto.dart';
import '../../../../../utils/link_utils.dart';

class InteractiveBulletinDialog {
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
    final imageUrls = bulletin.imageUrls;
    final hasImages = imageUrls.isNotEmpty;

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
                  _BulletinImageCarousel(
                    imageUrls: imageUrls,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    bulletin.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: DesignColor.neutral600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Linkify(
                    onOpen: LinkUtils.onOpenDescriptionLink,
                    options: const LinkifyOptions(humanize: false),
                    textAlign: TextAlign.start,
                    text: bulletin.content,
                    style: const TextStyle(
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

class _BulletinImageView extends StatelessWidget {
  final List<String> imageUrls;

  const _BulletinImageView({
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    if (imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrls.first,
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
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imageUrls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final imageUrl = imageUrls[index];

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                color: const Color(0xFFEAEAEA),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 28,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _BulletinImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const _BulletinImageCarousel({
    required this.imageUrls,
  });

  @override
  State<_BulletinImageCarousel> createState() => _BulletinImageCarouselState();
}

class _BulletinImageCarouselState extends State<_BulletinImageCarousel> {
  late final PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final imageUrl = widget.imageUrls[index];

                    return Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: const Color(0xFFEAEAEA),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            size: 36,
                          ),
                        );
                      },
                    );
                  },
                ),

                if (widget.imageUrls.length > 1)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${currentIndex + 1}/${widget.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        if (widget.imageUrls.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imageUrls.length, (index) {
              final isActive = index == currentIndex;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 7 : 6,
                height: isActive ? 7 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? DesignColor.actpodPrimary400
                      : const Color(0xFFD0D0D0),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
