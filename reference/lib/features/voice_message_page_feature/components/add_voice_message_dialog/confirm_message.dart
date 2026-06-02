import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/dto/voice_message_dto.dart';

class ConfirmMessage extends StatelessWidget {
  final VoiceMessageDto _voiceMessageDto;

  ConfirmMessage(this._voiceMessageDto);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230.w,
      child: Text(
        "你確定要將 ${_voiceMessageDto.listenerName} 與底下的語音留言加入故事嗎？\n點擊確定將前往編輯程序",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.w
        )
      ),
    );
  }
}