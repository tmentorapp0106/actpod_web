import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../components/avatar.dart';

class UserInfo extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Avatar("userId", null, 20.w),
        SizedBox(width: 3.w,),
        Text(
          "Username",
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.w
          ),
        )
      ]
    );
  }
}