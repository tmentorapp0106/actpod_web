import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/login_feature/login_screen.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../apiManagers/story_api_dto/get_one_story_res.dart';
import '../../send_voice_message_feature/send_voice_message_screen.dart';

class SendMessageButton extends ConsumerWidget {
  final GetOneStoryResItem storyInfo;

  SendMessageButton(this.storyInfo);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
      decoration: BoxDecoration(
        color: ConfigColor.primaryDefault,
        borderRadius: BorderRadius.circular(30.w),
      ),
      child: InkWell(
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
            barrierDismissible: false,
            context: context,
            builder: (context) {
              PlayerItemDto item = PlayerItemDto.fromGetOneStoryResItem(storyInfo);
              return SendVoiceMessageScreen(context, item);
            }
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              "assets/icons/voice_message.svg",
              color: Colors.white,
              width: 20.w,
              height: 20.w,
              fit: BoxFit.fitWidth,
            ),
            SizedBox(width: 2.w,),
            Text(
              storyInfo.userId == UserService.getUserInfo()?.userId? "添加語音" : "傳送語音",
              style: TextStyle(
                fontSize: 12.w,
                color: Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
}