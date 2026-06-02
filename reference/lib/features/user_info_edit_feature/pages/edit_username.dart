import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/features/user_info_edit_feature/controllers/edit_user_info_controller.dart';
import 'package:quick_share_app/providers.dart';

class EditUsernamePage extends ConsumerWidget {
  final EditUserInfoController _editUserInfoController;
  final TextEditingController _controller;

  EditUsernamePage(
    this._editUserInfoController,
    this._controller
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('帳號'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Call the updateUserInfo method from the controller
                ref.watch(loadingProvider.notifier).state = true;
                bool updated = await _editUserInfoController.updateUserInfo();
                ref.watch(loadingProvider.notifier).state = false;
                // Pop the current page after updating
                if(updated && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                '完成',
                style: TextStyle(
                  color: Color(0xff0067ed),
                  fontSize: 16
                ),
              ),
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
              const Text(
                '帳號',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '請輸入帳號',
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '只能輸入6~18位的英文字母、數字、點（.）或底線',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      )
    );
  }
}