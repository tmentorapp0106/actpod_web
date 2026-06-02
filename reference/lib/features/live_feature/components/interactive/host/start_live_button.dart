import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/features/live_feature/controllers/message_controller.dart';

import '../../../../../design_system/color.dart';

class StartLiveButton extends ConsumerWidget{
  final MessageController messageController;

  StartLiveButton({required this.messageController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        messageController.sendStartLiveKit();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: DesignColor.actpodPrimary400,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '開啟上麥環節',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
      )
    );
  }
}