import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/block_user_res.dart';
import 'package:quick_share_app/apiManagers/user_api_dto/remove_block_user_res.dart';
import 'package:quick_share_app/apiManagers/user_system_api_manager.dart';
import 'package:quick_share_app/components/avatar.dart';
import 'package:quick_share_app/features/block_user_feature/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';

class BlockUserScreen extends ConsumerStatefulWidget {
  const BlockUserScreen({super.key});

  @override
  ConsumerState<BlockUserScreen> createState() => _BlockUserScreenState();
}

class _BlockUserScreenState extends ConsumerState<BlockUserScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onKeywordChanged(String value) {
    ref.read(searchKeywordProvider.notifier).state = value;
  }

  Future<void> _blockSelected() async {
    final selected = ref.read(selectedUserProvider);

    if (selected == null) {
      ToastService.showNoticeToast("請先選擇用戶");
      return;
    }

    try {
      BlockUserRes response = await userApiManager.blockUser(selected.userId);
      if(response.code != "0000") {
        ToastService.showNoticeToast(response.message);
        return;
      }

      // 刷新 blocked list
      ref.invalidate(blockedUsersProvider);

      // 清空選擇＆搜尋（可依你喜好保留）
      ref.read(selectedUserProvider.notifier).state = null;
      _controller.clear();
      ref.read(searchKeywordProvider.notifier).state = '';

      if (mounted) {
        ToastService.showSuccessToast("已封鎖");
      }
    } catch (e) {
      if (mounted) {
        ToastService.showNoticeToast("封鎖失敗");
      }
    }
  }

  Future<void> _unblock(String userId) async {
    try {
      RemoveBlockUserRes response = await userApiManager.removeBlockUser(userId);
      if(response.code != "0000") {
        ToastService.showNoticeToast(response.message);
        return;
      }
      ref.invalidate(blockedUsersProvider);
    } catch (e) {
      ToastService.showNoticeToast("解除封鎖失敗");
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedUserProvider);

    final resultsAsync = ref.watch(searchResultsProvider);
    final blockedAsync = ref.watch(blockedUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('封鎖用戶'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1) Search TextField
            TextField(
              controller: _controller,
              onChanged: _onKeywordChanged,
              decoration: InputDecoration(
                labelText: '搜尋用戶',
                hintText: '輸入用戶名稱…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchKeywordProvider.notifier).state = '';
                    ref.read(selectedUserProvider.notifier).state = null;
                    setState(() {});
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Search results
            resultsAsync.when(
              data: (items) {
                if (ref.watch(searchKeywordProvider).trim().isEmpty) {
                  return const SizedBox.shrink();
                }
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('找不到符合的用戶'),
                  );
                }

                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Text('搜尋結果', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(height: 1),
                      ...items.map((u) {
                        final isSelected = selected?.userId == u.userId;
                        return ListTile(
                          leading: Avatar(u.userId, u.avatarUrl, 28),
                          title: Text(u.nickname),
                          trailing: isSelected ? const Icon(Icons.check) : null,
                          onTap: () => ref.read(selectedUserProvider.notifier).state = u,
                        );
                      }),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('搜尋失敗：$e'),
              ),
            ),

            const SizedBox(height: 12),

            // 2) Block button (selected user)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('已選擇用戶', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (selected == null)
                      const Text('尚未選擇')
                    else
                      Row(
                        children: [
                          Avatar(selected.userId, selected.avatarUrl, 28),
                          const SizedBox(width: 12),
                          Expanded(child: Text(selected.nickname)),
                        ],
                      ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: selected == null ? null : _blockSelected,
                      icon: const Icon(Icons.block),
                      label: const Text('送出封鎖'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3) Blocked users list
            const Text('已封鎖用戶列表', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            blockedAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Text('目前沒有封鎖任何用戶。');
                }
                return Card(
                  child: Column(
                    children: items.map((u) {
                      return ListTile(
                        leading: Avatar(u.userId, u.avatarUrl, 24),
                        title: Text(u.nickname),
                        trailing: TextButton(
                          onPressed: () => _unblock(u.userId),
                          child: const Text('解除'),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('讀取封鎖列表失敗：$e'),
            ),
          ],
        ),
      ),
    );
  }
}