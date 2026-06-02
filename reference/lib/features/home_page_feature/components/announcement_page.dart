import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

class AnnouncementPage extends StatelessWidget {
  final String announcementImageUrl;

  AnnouncementPage(this.announcementImageUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConfigColor.background,
      appBar: AppBar(
        backgroundColor: ConfigColor.background,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 20.h),
            width: 360.w,
            child: Image.network(
              announcementImageUrl,
              fit: BoxFit.fitWidth,
            ),
          ),
        )
      ),
    );
  }
}