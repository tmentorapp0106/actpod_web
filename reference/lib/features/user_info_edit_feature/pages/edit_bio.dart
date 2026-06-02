import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/user_info_edit_feature/controllers/edit_user_info_controller.dart';

import '../../../components/whole_page_loading.dart';
import '../../../providers.dart';

class EditBioPage extends ConsumerWidget {
  final TextEditingController _controller;
  final EditUserInfoController _editUserInfoController;
  final int maxLength = 200;

  EditBioPage(
    this._controller,
    this._editUserInfoController,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bio'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                ref.watch(loadingProvider.notifier).state = true;
                bool updated = await _editUserInfoController.updateUserInfo();
                ref.watch(loadingProvider.notifier).state = false;
                if(updated && context.mounted) {
                  Navigator.of(context).pop();
                }
              }, // Disable "完成"
              child: const Text(
                '完成',
                style: TextStyle(
                  color: Color(0xff0067ed),
                  fontSize: 16
                ),
              )
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bio', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Stack(
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 8,
                    maxLength: maxLength,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12),
                      hintText: '請輸入個人簡介',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          _controller.clear();
                        },
                        child: const Icon(Icons.clear, size: 20),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}