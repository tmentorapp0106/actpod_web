import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/live_page/components/bulletin_dialog.dart';
import 'package:actpod_web/features/live_page/controllers/message_controller.dart';
import 'package:actpod_web/features/live_page/controllers/room_controller.dart';
import 'package:actpod_web/features/live_page/providers/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BulletinPreview extends ConsumerWidget {
  final RoomController roomController;
  final MessageController messageController;

  BulletinPreview({required this.roomController, required this.messageController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomInfo = ref.watch(roomInfoProvider);
    if(ref.watch(bulletinsProvider).isEmpty || roomInfo == null) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () {
        BulletinDialog().show(
          context,
          bulletins: ref.watch(bulletinsProvider)
        );
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