import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design_system/color.dart';
import '../controllers/channel_controller.dart';
import '../screens/edit_channel_screen.dart';

class EditButton extends ConsumerWidget {
  final ChannelController channelController;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  EditButton({required this.channelController, required this.nameController, required this.descriptionController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
        child: OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditChannelScreen(
                channelController,
                nameController,
                descriptionController
              ),
            ));
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: DesignColor.neutral500,
            side: const BorderSide(color: DesignColor.neutral500, width: 1.5),
            shape: const StadiumBorder(), // ✅ 膠囊形
            // padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, size: 20, color: DesignColor.neutral500),
              const SizedBox(width: 8),
              Text(
                "編輯",
                style: TextStyle(
                  color: DesignColor.neutral500,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5, // 讓字距像圖那樣鬆一點
                ),
              ),
            ],
          ),
        )
    );
  }
}