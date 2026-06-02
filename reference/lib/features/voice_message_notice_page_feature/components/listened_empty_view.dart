import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/color.dart'; // 提供 DesignColor.primary50

class ListenedEmptyView extends StatelessWidget {
  const ListenedEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    // 若你的專案已在上層初始化 ScreenUtil，這裡可直接用 .w/.h/.sp
    final primary = DesignColor.primary50; // 橘色主色（可改你們自己的）
    final textDefault = ConfigColor.textColorDefault; // 你的預設文字色
    final hint = Colors.grey; // 次要提示色

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 200.h),
              Text(
                '目前尚無語音留言動態',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: hint.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.h),
              Text(
                '可至 Story 下方「錄製語音留言」新增語音留言',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: hint.withOpacity(0.85),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24.h),

              SvgPicture.asset('assets/icons/voice_message/record_button.svg',
                  width: 320.w),
            ],
          ),
        ),
      ),
    );
  }
}
