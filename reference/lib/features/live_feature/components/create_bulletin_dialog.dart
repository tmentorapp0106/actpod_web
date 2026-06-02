import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quick_share_app/design_system/color.dart';

import '../../../utils/image_utils.dart';

class CreateBulletinDialog {
  Future<bool?> show(
      BuildContext context, {
        Future<void> Function({
        required String title,
        required String content,
        required List<String> imagePaths,
      })? onSubmit,
      }) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    List<String> selectedImagePaths = [];

    bool titleError = false;
    bool contentError = false;
    bool isSubmitting = false;

    return await showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      useSafeArea: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {},
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 520,
                          maxHeight: MediaQuery.of(context).size.height * 0.85,
                        ),
                        child: Dialog(
                          insetPadding: EdgeInsets.zero,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: SingleChildScrollView(
                            keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          '設定公告',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: isSubmitting
                                            ? null
                                            : () => Navigator.of(dialogContext).pop(),
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
                                  _dialogTextField(
                                    context: context,
                                    controller: titleController,
                                    hintText: 'title',
                                    maxLines: 1,
                                    hasError: titleError,
                                    enabled: !isSubmitting,
                                    onChanged: (_) {
                                      if (titleError &&
                                          titleController.text.trim().isNotEmpty) {
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
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
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
                                  _dialogTextField(
                                    context: context,
                                    controller: contentController,
                                    hintText: 'text',
                                    maxLines: 4,
                                    hasError: contentError,
                                    enabled: !isSubmitting,
                                    onChanged: (_) {
                                      if (contentError &&
                                          contentController.text.trim().isNotEmpty) {
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
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
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
                                            cropImageFunc: (file) => ImageUtils.cropImageFunc(file, 720, 720),
                                            maxCount: 10,
                                          );

                                          if (selectedFiles != null && selectedFiles.isNotEmpty) {
                                            setState(() {
                                              selectedImagePaths = selectedFiles.map((file) => file.path).toList();
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
                                                selectedImagePaths.isEmpty
                                                    ? '選擇圖片'
                                                    : '重新選擇圖片 (${selectedImagePaths.length}/10)',
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

                                      if (selectedImagePaths.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        GridView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: selectedImagePaths.length,
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                          itemBuilder: (context, index) {
                                            final imagePath = selectedImagePaths[index];

                                            return Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: Image.file(
                                                      File(imagePath),
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
                                                        selectedImagePaths.removeAt(index);
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
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 18),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: isSubmitting
                                          ? null
                                          : () async {
                                        FocusScope.of(context).unfocus();

                                        final title =
                                        titleController.text.trim();
                                        final content =
                                        contentController.text.trim();

                                        final newTitleError =
                                            title.isEmpty;
                                        final newContentError =
                                            content.isEmpty;

                                        setState(() {
                                          titleError = newTitleError;
                                          contentError = newContentError;
                                        });

                                        if (newTitleError ||
                                            newContentError) {
                                          return;
                                        }

                                        setState(() {
                                          isSubmitting = true;
                                        });

                                        try {
                                          await onSubmit?.call(
                                            title: title,
                                            content: content,
                                            imagePaths: selectedImagePaths,
                                          );

                                          if (dialogContext.mounted) {
                                            Navigator.of(dialogContext).pop(true);
                                          }
                                        } catch (e) {
                                          setState(() {
                                            isSubmitting = false;
                                          });
                                          if (dialogContext.mounted) {
                                            Navigator.of(dialogContext).pop();
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        DesignColor.actpodPrimary400,
                                        foregroundColor: Colors.black,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: isSubmitting
                                          ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                            Colors.black,
                                          ),
                                        ),
                                      )
                                          : const Text(
                                        '公告',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

  Widget _dialogTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hintText,
    required bool hasError,
    required ValueChanged<String> onChanged,
    required bool enabled,
    int maxLines = 1,
  }) {
    const normalBorderColor = Color(0xFFD3D3D3);
    const errorColor = Colors.red;

    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      onChanged: onChanged,
      textInputAction:
      maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: errorColor,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: errorColor,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}