import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/avatar.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/live_feature/components/listen_together/audience/bulletin_dialog.dart';
import 'package:quick_share_app/features/live_feature/components/listen_together/host/bulletin_dialog.dart';
import 'package:quick_share_app/features/live_feature/controllers/message_controller.dart';
import 'package:quick_share_app/features/live_feature/controllers/room_controller.dart';
import 'package:quick_share_app/features/live_feature/providers.dart';

class BulletinPreview extends ConsumerWidget {
  final String screen;
  final RoomController roomController;
  final MessageController messageController;

  BulletinPreview({required this.screen, required this.roomController, required this.messageController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomInfo = ref.watch(roomInfoProvider);
    if(ref.watch(bulletinsProvider).isEmpty || roomInfo == null) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () {
        if(screen == "listen_together_audience" || screen == "interactive_audience") {
          AudienceBulletinDialog().show(
            context,
            bulletins: ref.watch(bulletinsProvider)
          );
        } else {
          HostBulletinDialog().show(
            context,
            bulletins: ref.watch(bulletinsProvider),
            onDelete: ({
              required String bulletinId,
            }) async {
              await roomController.deleteBulletin(
                  bulletinId
              );
              messageController.sendDeletedBulletin();
              if(context.mounted) {
                Navigator.of(context).pop();
              }
            },
            onUpdate: ({
              required String bulletinId,
              required String title,
              required String content,
              required List<String> existingImageUrls,
              required List<String> newImagePaths,
            }) async {
              final newFiles = newImagePaths.map((path) => File(path)).toList();

              await roomController.updateBulletin(
                bulletinId,
                title,
                content,
                existingImageUrls,
                newFiles,
              );
              messageController.sendUpdatedBulletin();
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: DesignColor.actpodPrimary50,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    "公告",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 2,),
                Icon(
                  Icons.volume_up_rounded,
                  color: DesignColor.actpodPrimary400,
                )
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: ' ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: ref.watch(bulletinsProvider).first.title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}


