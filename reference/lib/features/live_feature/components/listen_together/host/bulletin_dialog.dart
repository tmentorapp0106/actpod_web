import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../../../dto/room_bulletin_dto.dart';
import '../../../../../utils/image_utils.dart';
import '../../../../../utils/link_utils.dart';

enum _BulletinPage {
  list,
  detail,
  edit,
}

class HostBulletinDialog {
  Future<void> show(
      BuildContext context, {
        required List<RoomBulletinDto> bulletins,

        Future<void> Function({
          required String bulletinId,
          required String title,
          required String content,
          required List<String> existingImageUrls,
          required List<String> newImagePaths,
        })? onUpdate,

        Future<void> Function({
          required String bulletinId,
        })? onDelete,
      }) async {
    RoomBulletinDto? selectedBulletin;
    _BulletinPage page = _BulletinPage.list;

    await showDialog(
      context: context,
      barrierDismissible: true,
      useSafeArea: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget child;

            switch (page) {
              case _BulletinPage.list:
                child = _BulletinListView(
                  key: const ValueKey('list'),
                  bulletins: bulletins,
                  onTapBulletin: (bulletin) {
                    setState(() {
                      selectedBulletin = bulletin;
                      page = _BulletinPage.detail;
                    });
                  },
                  onClose: () {
                    Navigator.of(dialogContext).pop();
                  },
                );
                break;

              case _BulletinPage.detail:
                child = _BulletinDetailView(
                  key: const ValueKey('detail'),
                  bulletin: selectedBulletin!,
                  onBack: () {
                    setState(() {
                      selectedBulletin = null;
                      page = _BulletinPage.list;
                    });
                  },
                  onEdit: () {
                    setState(() {
                      page = _BulletinPage.edit;
                    });
                  },
                  onClose: () {
                    Navigator.of(dialogContext).pop();
                  },
                );
                break;

              case _BulletinPage.edit:
                child = _BulletinEditView(
                  key: ValueKey('edit_${selectedBulletin!.bulletinId}'),
                  bulletin: selectedBulletin!,
                  onBack: () {
                    setState(() {
                      page = _BulletinPage.detail;
                    });
                  },
                  onClose: () {
                    Navigator.of(dialogContext).pop();
                  },
                  onDelete: ({
                    required String bulletinId,
                  }) async {
                    await onDelete?.call(
                      bulletinId: bulletinId,
                    );

                    if (context.mounted) {
                      setState(() {
                        selectedBulletin = null;
                        page = _BulletinPage.list;
                      });
                    }
                  },
                  onSubmit: ({
                    required String bulletinId,
                    required String title,
                    required String content,
                    required List<String> existingImageUrls,
                    required List<String> newImagePaths,
                  }) async {
                    await onUpdate?.call(
                      bulletinId: bulletinId,
                      title: title,
                      content: content,
                      existingImageUrls: existingImageUrls,
                      newImagePaths: newImagePaths,
                    );

                    if (context.mounted) {
                      setState(() {
                        selectedBulletin = null;
                        page = _BulletinPage.list;
                      });
                    }
                  },
                );
                break;
            }

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
                        child: child,
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
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                child: Icon(
                  Icons.alarm_on_rounded,
                  size: 20,
                  color: DesignColor.actpodPrimary400,
                ),
              ),
              Expanded(
                child: Text(
                  bulletin.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
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
  final VoidCallback onEdit;
  final VoidCallback onClose;

  const _BulletinDetailView({
    super.key,
    required this.bulletin,
    required this.onBack,
    required this.onEdit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrls = bulletin.imageUrls;
    final hasImage = imageUrls.isNotEmpty;

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
                onTap: onEdit,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 4),
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
                    _BulletinImageCarousel(
                      imageUrls: imageUrls,
                    ),
                    const SizedBox(height: 12),
                  ],
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

class _BulletinEditView extends StatefulWidget {
  final RoomBulletinDto bulletin;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final Future<void> Function({
  required String bulletinId,
  required String title,
  required String content,
  required List<String> existingImageUrls,
  required List<String> newImagePaths,
  }) onSubmit;
  final Future<void> Function({
  required String bulletinId,
  }) onDelete;

  const _BulletinEditView({
    super.key,
    required this.bulletin,
    required this.onBack,
    required this.onClose,
    required this.onSubmit,
    required this.onDelete
  });

  @override
  State<_BulletinEditView> createState() => _BulletinEditViewState();
}

class _BulletinEditViewState extends State<_BulletinEditView> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  late List<String> existingImageUrls;
  List<String> newImagePaths = [];
  bool titleError = false;
  bool contentError = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.bulletin.title);
    _contentController = TextEditingController(text: widget.bulletin.content);
    existingImageUrls = List<String>.from(widget.bulletin.imageUrls);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Widget _buildImagesGrid() {
    final allImages = [
      ...existingImageUrls.map((url) => _BulletinImageItem(
        pathOrUrl: url,
        isNetwork: true,
      )),
      ...newImagePaths.map((path) => _BulletinImageItem(
        pathOrUrl: path,
        isNetwork: false,
      )),
    ];

    if (allImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allImages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final item = allImages[index];

        return Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.isNetwork
                    ? Image.network(
                  item.pathOrUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: const Color(0xFFEAEAEA),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 24,
                      ),
                    );
                  },
                )
                    : Image.file(
                  File(item.pathOrUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: isSubmitting
                    ? null
                    : () {
                  setState(() {
                    if (item.isNetwork) {
                      existingImageUrls.remove(item.pathOrUrl);
                    } else {
                      newImagePaths.remove(item.pathOrUrl);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: isSubmitting ? null : widget.onBack,
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
                    '編輯公告',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
                InkWell(
                  onTap: isSubmitting ? null : widget.onClose,
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
            const SizedBox(height: 12),

            const Text(
              '標題 (釘選在聊天室)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 4),
            _EditField(
              controller: _titleController,
              hintText: 'title',
              maxLines: 1,
              hasError: titleError,
              enabled: !isSubmitting,
              onChanged: (_) {
                if (titleError && _titleController.text.trim().isNotEmpty) {
                  setState(() {
                    titleError = false;
                  });
                }
              },
            ),
            if (titleError) ...[
              const SizedBox(height: 4),
              const Text(
                '請輸入標題',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],

            const SizedBox(height: 12),

            const Text(
              '內文',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 8),
            _EditField(
              controller: _contentController,
              hintText: 'text',
              maxLines: 6,
              hasError: contentError,
              enabled: !isSubmitting,
              onChanged: (_) {
                if (contentError && _contentController.text.trim().isNotEmpty) {
                  setState(() {
                    contentError = false;
                  });
                }
              },
            ),
            if (contentError) ...[
              const SizedBox(height: 4),
              const Text(
                '請輸入內文',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],

            const SizedBox(height: 12),

            const Text(
              '圖片 (選填)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: isSubmitting
                      ? null
                      : () async {
                    FocusScope.of(context).unfocus();

                    final selectedFiles = await ImageUtils.pickMultipleMedia(
                      fromGallery: true,
                      cropImageFunc: null,
                      maxCount: 10,
                    );

                    if (selectedFiles != null && selectedFiles.isNotEmpty) {
                      setState(() {
                        newImagePaths.addAll(
                          selectedFiles.map((file) => file.path),
                        );

                        final totalCount =
                            existingImageUrls.length + newImagePaths.length;

                        if (totalCount > 10) {
                          final overflow = totalCount - 10;

                          if (overflow > 0 && newImagePaths.length >= overflow) {
                            newImagePaths.removeRange(
                              newImagePaths.length - overflow,
                              newImagePaths.length,
                            );
                          }
                        }
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFD0D0D0),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.file_upload_outlined,
                          size: 20,
                          color: Color(0xFF666666),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '選擇圖片 (${existingImageUrls.length + newImagePaths.length}/10)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (existingImageUrls.isNotEmpty || newImagePaths.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildImagesGrid(),
                ],
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: isSubmitting ? null : () async {
                        await widget.onDelete(
                          bulletinId: widget.bulletin.bulletinId,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF6B6B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '刪除',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                        FocusScope.of(context).unfocus();

                        final title = _titleController.text.trim();
                        final content = _contentController.text.trim();

                        final newTitleError = title.isEmpty;
                        final newContentError = content.isEmpty;

                        setState(() {
                          titleError = newTitleError;
                          contentError = newContentError;
                        });

                        if (newTitleError || newContentError) return;

                        setState(() {
                          isSubmitting = true;
                        });

                        try {
                          await widget.onSubmit(
                            bulletinId: widget.bulletin.bulletinId,
                            title: title,
                            content: content,
                            existingImageUrls: existingImageUrls,
                            newImagePaths: newImagePaths,
                          );
                        } catch (e) {
                          if (!mounted) return;
                          setState(() {
                            isSubmitting = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignColor.actpodPrimary400,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      )
                          : const Text(
                        '完成',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool hasError;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final int maxLines;

  const _EditField({
    required this.controller,
    required this.hintText,
    required this.hasError,
    required this.enabled,
    required this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    const normalBorderColor = Color(0xFFD3D3D3);
    const errorColor = Colors.red;

    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      onChanged: onChanged,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF333333),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF9A9A9A),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? errorColor : normalBorderColor,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? errorColor : normalBorderColor,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class _BulletinImageItem {
  final String pathOrUrl;
  final bool isNetwork;

  const _BulletinImageItem({
    required this.pathOrUrl,
    required this.isNetwork,
  });
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
