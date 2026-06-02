import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/create_podcast_store_res.dart';
import 'package:quick_share_app/apiManagers/channel_system_api_manager.dart';
import 'package:quick_share_app/apiManagers/upload_system_api_manager.dart';
import 'package:quick_share_app/services/toast_service.dart';

import '../../../apiManagers/upload_api_dto/get_upload_url_res.dart';
import '../../../components/back_button.dart';
import '../../../utils/image_utils.dart';
import '../dto/link_form_item.dart';

class CreatePodcastStoreScreen extends StatefulWidget {
  const CreatePodcastStoreScreen({super.key});

  @override
  State<CreatePodcastStoreScreen> createState() => _CreatePodcastStoreScreenState();
}

class _CreatePodcastStoreScreenState extends State<CreatePodcastStoreScreen> {
  static const Color themeColor = Color(0xFFffbc1f);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _instagramUrlController = TextEditingController();
  final TextEditingController _facebookUrlController = TextEditingController();
  final TextEditingController _threadsUrlController = TextEditingController();
  final TextEditingController _youtubeUrlController = TextEditingController();

  XFile? _storeImageFile;
  bool _isLoading = false;

  final List<LinkFormItem> _links = [
    LinkFormItem(),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instagramUrlController.dispose();
    _facebookUrlController.dispose();
    _threadsUrlController.dispose();
    _youtubeUrlController.dispose();

    for (final link in _links) {
      link.dispose();
    }
    super.dispose();
  }

  Future<void> _pickStoreImage() async {
    File? selectFile = await ImageUtils.pickMedia(true, (file) => ImageUtils.cropImageFunc(file, 720, 720));
    if (selectFile == null) return;

    setState(() {
      _storeImageFile = XFile(selectFile.path);
    });
  }

  Future<void> _pickLinkImage(int index) async {
    File? selectFile = await ImageUtils.pickMedia(true, (file) => ImageUtils.cropImageFunc(file, 50, 400));
    if (selectFile == null) return;

    setState(() {
      _links[index].pickedImage =  XFile(selectFile.path);
    });
  }

  void _addLink() {
    setState(() {
      _links.add(LinkFormItem());
    });
  }

  void _removeLink(int index) {
    if (_links.length == 1) return;
    setState(() {
      final item = _links.removeAt(index);
      item.dispose();
    });
  }

  void _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    if(_links.isEmpty) {
      ToastService.showNoticeToast("請至少新增一個 Link");
      setState(() {
        _isLoading = false;
      });
      return;
    }
    for(LinkFormItem link in _links) {
      if(link.pickedImage == null || link.urlController.text.isEmpty) {
        ToastService.showNoticeToast("Link 資料不完整");
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    String podcastStoreImageUrl = "";
    GetUploadUrlRes uploadImageRes = await uploadApiManager.uploadPodcastStoreImage(File(_storeImageFile!.path));
    if(uploadImageRes.code != "0000") {
      ToastService.showNoticeToast("上傳 Podcast store image 失敗");
      setState(() {
        _isLoading = false;
      });
      return;
    }
    podcastStoreImageUrl = uploadImageRes.data!.publicUrl;

    for(LinkFormItem link in _links) {
      uploadImageRes = await uploadApiManager.uploadPodcastStoreImage(File(link.pickedImage!.path));
      if(uploadImageRes.code != "0000") {
        ToastService.showNoticeToast("上傳連結照片失敗");
        setState(() {
          _isLoading = false;
        });
        return;
      }
      link.imageUrl = uploadImageRes.data!.publicUrl;
    }

    CreatePodcastStoreRes createPodcastStoreRes = await channelApiManager.createPodcastStore(
      _nameController.text,
      _descriptionController.text,
      podcastStoreImageUrl,
      _instagramUrlController.text,
      _facebookUrlController.text,
      _threadsUrlController.text,
      _youtubeUrlController.text,
      _links
    );
    if(createPodcastStoreRes.code != "0000") {
      ToastService.showNoticeToast("建立 Podcast store 失敗");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if(context.mounted) {
      Navigator.of(context).pop();
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(32), // 你要多矮就改這個
        child: AppBar(
          leading: ActPodBackButton(),
          title: Text(
            "建立 Podcast Store"
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 28,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('商店資料'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Podcast Store 名稱',
                      hint: '請輸入 Podcast Store 名稱',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '請輸入名稱';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: '簡短介紹',
                      hint: '請輸入 Podcast Store 介紹',
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '請輸入介紹';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Podcast Store 主圖'),
                    const SizedBox(height: 12),
                    _buildImagePreview(
                      imagePath: _storeImageFile?.path,
                      emptyText: '尚未選擇商店圖片',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickStoreImage,
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('選擇圖片'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              side: const BorderSide(color: themeColor),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('社群連結'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _instagramUrlController,
                      label: 'Instagram URL',
                      hint: 'https://instagram.com/...',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _facebookUrlController,
                      label: 'Facebook URL',
                      hint: 'https://facebook.com/...',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _threadsUrlController,
                      label: 'Threads URL',
                      hint: 'https://threads.net/...',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _youtubeUrlController,
                      label: 'YouTube URL',
                      hint: 'https://youtube.com/...',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: _SectionTitle('自訂 Links')),
                        FilledButton.icon(
                          onPressed: _addLink,
                          icon: const Icon(Icons.add),
                          label: const Text('新增'),
                          style: FilledButton.styleFrom(
                            backgroundColor: themeColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_links.length, (index) {
                      final item = _links[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFE39A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Link ${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => _removeLink(index),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                            _buildImagePreview(
                              imagePath: item.pickedImage?.path,
                              emptyText: '尚未選擇 Link 圖片',
                              height: 50,
                              width: 400
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () => _pickLinkImage(index),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('選擇 Link 圖片'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: const BorderSide(color: themeColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: item.urlController,
                              label: 'Link URL',
                              hint: 'https://...',
                              validator: (value) {
                                final urlValue = value?.trim() ?? '';

                                if (item.pickedImage != null && urlValue.isEmpty) {
                                  return '有圖片時請輸入對應連結';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _isLoading? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white
                  ),
                ) : const Text(
                  '建立 Podcast Store',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFE39A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: themeColor, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildImagePreview({
    required String? imagePath,
    required String emptyText,
    double height = 280,
    double width = 280
  }) {
    final hasImage = imagePath != null && imagePath.isNotEmpty;

    return Center(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE39A)),
        ),
        alignment: Alignment.center,
        child: hasImage
            ? ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(imagePath),
            fit: BoxFit.fitWidth,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  imagePath,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              );
            },
          ),
        )
            : Text(
          emptyText,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
      )
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }
}
