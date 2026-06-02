
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../login_feature/login_screen.dart';
import '../controllers/voice_message_controller.dart';

class LoginView extends StatelessWidget {
  final VoiceMessageController _voiceMessageController;

  LoginView(this._voiceMessageController);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(15.w),
        color: ConfigColor.primaryDefault,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.w),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return LoginPageScreen();
              }
            ).then((value) {
              if(UserService.getUserToken() != null && UserService.getUserToken() != "") {
                _voiceMessageController.getVoiceMessages(context, true);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
            child: Text(
              "Login",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),
          ),
        ),
      ),
    );
  }
}