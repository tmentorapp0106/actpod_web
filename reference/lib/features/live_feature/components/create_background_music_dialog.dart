import 'package:flutter/material.dart';
import 'package:quick_share_app/design_system/color.dart';

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quick_share_app/features/live_feature/controllers/room_controller.dart';

class CreateBackgroundMusicDialog {
  Future<BackgroundMusicDialogResult?> show(
      BuildContext context,
      RoomController roomController
  ) async {
    final nameController = TextEditingController();

    bool hasNameError = false;
    bool hasFileError = false;
    bool isSubmitting = false;

    PlatformFile? selectedFile;

    final result = await showDialog<BackgroundMusicDialogResult>(
      context: context,
      barrierDismissible: !isSubmitting,
      useSafeArea: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickMp3File() async {
              FocusScope.of(context).unfocus();

              final fileResult = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['mp3'],
                allowMultiple: false,
                withData: false,
              );

              if (fileResult != null && fileResult.files.isNotEmpty) {
                setState(() {
                  selectedFile = fileResult.files.first;
                  hasFileError = false;

                  if (nameController.text.trim().isEmpty) {
                    final fileName = selectedFile!.name;
                    final dotIndex = fileName.lastIndexOf('.');
                    nameController.text = dotIndex > 0
                        ? fileName.substring(0, dotIndex)
                        : fileName;
                  }
                });
              }
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Dialog(
                      insetPadding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
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
                                    '建立背景音樂',
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
                              '音樂檔案',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF777777),
                              ),
                            ),
                            const SizedBox(height: 8),

                            InkWell(
                              onTap: isSubmitting ? null : pickMp3File,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: hasFileError
                                        ? Colors.red
                                        : const Color(0xFFD3D3D3),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.audio_file_outlined),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        selectedFile?.name ?? '選擇 mp3 檔案',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: selectedFile == null
                                              ? const Color(0xFF9A9A9A)
                                              : const Color(0xFF333333),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.upload_file),
                                  ],
                                ),
                              ),
                            ),

                            if (hasFileError) ...[
                              const SizedBox(height: 4),
                              const Text(
                                '請選擇 mp3 檔案',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            const Text(
                              '音樂名稱',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF777777),
                              ),
                            ),
                            const SizedBox(height: 8),

                            TextField(
                              controller: nameController,
                              enabled: !isSubmitting,
                              onTapOutside: (_) =>
                                  FocusScope.of(context).unfocus(),
                              onChanged: (_) {
                                if (hasNameError &&
                                    nameController.text.trim().isNotEmpty) {
                                  setState(() {
                                    hasNameError = false;
                                  });
                                }
                              },
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF333333),
                              ),
                              decoration: InputDecoration(
                                hintText: '請輸入音樂名稱',
                                hintStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9A9A9A),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: hasNameError
                                        ? Colors.red
                                        : const Color(0xFFD3D3D3),
                                    width: 1.2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: hasNameError
                                        ? Colors.red
                                        : const Color(0xFFD3D3D3),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            if (hasNameError) ...[
                              const SizedBox(height: 4),
                              const Text(
                                '請輸入音樂名稱',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: isSubmitting
                                          ? null
                                          : () async {
                                        FocusScope.of(context).unfocus();

                                        final musicName =
                                        nameController.text.trim();

                                        setState(() {
                                          hasFileError =
                                              selectedFile == null;
                                          hasNameError =
                                              musicName.isEmpty;
                                        });

                                        if (selectedFile == null ||
                                            musicName.isEmpty) {
                                          return;
                                        }

                                        if (selectedFile!.path == null) {
                                          setState(() {
                                            hasFileError = true;
                                          });
                                          return;
                                        }

                                        setState(() {
                                          isSubmitting = true;
                                        });

                                        await roomController.createBackgroundMusic(File(selectedFile!.path!), musicName);

                                        setState(() {
                                          isSubmitting = false;
                                        });
                                        if(context.mounted) {
                                          Navigator.of(context).pop();
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
                                          AlwaysStoppedAnimation<
                                              Color>(Colors.black),
                                        ),
                                      )
                                          : const Text(
                                        '確定',
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
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    return result;
  }
}

class BackgroundMusicDialogResult {
  final String? musicName;
  final File? file;
  final String? fileName;

  const BackgroundMusicDialogResult._({
    this.musicName,
    this.file,
    this.fileName,
  });

  const BackgroundMusicDialogResult.selected({
    required String musicName,
    required File file,
    required String fileName,
  }) : this._(
    musicName: musicName,
    file: file,
    fileName: fileName,
  );
}