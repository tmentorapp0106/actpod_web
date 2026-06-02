import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/design.dart';
import '../../../../design_system/color.dart';
import '../../../../services/user_service.dart';
import '../../../login_feature/login_screen.dart';
import '../../controllers/recorder_controller.dart';
import '../../providers/providers.dart';

class RecordButtonWidget extends ConsumerWidget {
  final RecordController recordController;

  RecordButtonWidget(this.recordController, {super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordStatus = ref.watch(recordStatusProvider);

    return recordBtn(ref, context, recordStatus);
  }

  Widget recordBtn(WidgetRef ref, BuildContext context, String recordStatus) {
    if(recordStatus == "pending") {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          recordController.startRecord();
        },
        child: Container(
          height: 64.h,
          width: 312.w,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 1),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic_rounded, size: 24.w, color: DesignColor.primary50),
              SizedBox(width: 10),
              Text(
                '或者，直接開始錄音',
                style: TextStyle(
                  fontSize: 16.w,
                  color: DesignColor.primary50,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Ink(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Material(
        color: DesignSystem.primary,
        shape: CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            if(!UserService.hasLoggedIn()) {
              await showDialog(
                  context: context,
                  builder: (context) {
                    return LoginPageScreen();
                  }
              );
              return;
            }
            final recordStatus = ref.watch(recordStatusProvider);
            if(recordStatus == "pending") {
              recordController.startRecord();
            } else if(recordStatus == "recording") {
              recordController.pauseRecord();
            } else {
              recordController.resumeRecording();
            }
          },
          child: buttons(recordStatus, ref)
        )
      )
    );
  }

  Widget buttons(String recordStatus, WidgetRef ref) {
    if(recordStatus == "pending") {
      return Container(
        width: 80.w,
        height: 80.w,
        padding: EdgeInsets.all(12.w),
        child: Image.asset(
          "assets/icons/mic.png",
          fit: BoxFit.fitWidth,
          color: Colors.white,
        )
      );
    } else if(recordStatus == "recording") {
      return SizedBox(
        width: 80.w,
        height: 80.w,
        child: Icon(
          Icons.pause_rounded,
          color: Colors.white,
          size: 56.w
        )
      );
    } else {
      return SizedBox(
        width: 76.w,
        height: 76.w,
        child: Center(
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 56.w
          )
        )
      );
    }
  }
}