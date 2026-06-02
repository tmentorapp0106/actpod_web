import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// for deeplink usage, temp page
class PlaceHolderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Image.asset(
          "assets/images/logo_transparent.png",
          width: 250.w,
          fit: BoxFit.fitWidth
        )
      ),
    );
  }
}