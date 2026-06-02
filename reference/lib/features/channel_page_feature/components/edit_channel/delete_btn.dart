import 'package:flutter/material.dart';
import 'package:quick_share_app/features/channel_page_feature/components/edit_channel/delete_dialog.dart';
import 'package:quick_share_app/features/channel_page_feature/controllers/channel_controller.dart';

class DeleteBtn extends StatelessWidget {
  final ChannelController channelController;
  final String channelId;

  DeleteBtn(this.channelController, this.channelId);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        bool? delete = await DeleteDialog(context).show();
        if(delete != null && delete) {
          await channelController.deleteChannel(channelId);
          if(context.mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
        }
      },
      icon: Icon(Icons.delete_forever_rounded, color: Colors.red),
    );
  }
}