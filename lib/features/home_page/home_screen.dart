import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isPhone = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: Colors.black,
      body: isPhone? mobile() : web()
    );
  }

  Widget web() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/actpod_logo_web.png",
            width: 140.w,
          ),
          SizedBox(height: 20.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/apple_download.png",
                width: 60.w,
              ),
              SizedBox(width: 12.w,),
              Image.asset(
                "assets/images/google_download.png",
                width: 66.w,
              ),
            ],
          )
        ]
      )
    );
  }

  Widget mobile() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/actpod_logo_web.png",
            width: 260.w,
          ),
          SizedBox(height: 12.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/apple_download.png",
                width: 100.w,
              ),
              SizedBox(width: 12.w,),
              Image.asset(
                "assets/images/google_download.png",
                width: 108.w,
              ),
            ],
          )
        ]
      )
    );
  }
}