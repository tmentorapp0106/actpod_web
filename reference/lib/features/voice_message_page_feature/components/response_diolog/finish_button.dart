import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/dto/voice_message_dto.dart';
import 'package:quick_share_app/features/voice_message_page_feature/components/response_diolog/send_dialog.dart';

import '../../../../services/user_service.dart';
import '../../../login_feature/login_screen.dart';
import '../../controllers/record_controller.dart';
import '../../controllers/send_controller.dart';

class FinishButton extends ConsumerWidget {
  final VoiceMessageDto _voiceMessageDto;
  final SendController _sendController;
  final RecordController _recordController;
  final BuildContext _dialogContext;

  FinishButton(this._voiceMessageDto, this._sendController, this._recordController, this._dialogContext);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            if(!UserService.hasLoggedIn()) {
              showDialog(
                context: context,
                builder: (context) {
                  return LoginPageScreen();
                }
              );
              return;
            }
            showDialog(
              context: _dialogContext,
              builder: (context) {
                return SendDialog(_sendController, _recordController, _voiceMessageDto, _dialogContext);
              }
            );
          },
          child: Icon(
            Icons.send,
            color: ConfigColor.primaryDefault,
            size: 20.w
          )
        ),
        Text(
          "傳送",
          style: TextStyle(
            fontSize: 12.w
          ),
        )
      ]
    );
  }
}