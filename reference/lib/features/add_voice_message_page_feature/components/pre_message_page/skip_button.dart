import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

import '../../providers.dart';

class SkipBtn extends ConsumerWidget {
  final PageController _pageController;

  SkipBtn(this._pageController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return skipBtn(context, ref);
  }

  Widget skipBtn(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(preMessageRecordStatusProvider) == "pending",
      child: InkWell(
        onTap: () async {
          if(_pageController.page == null || _pageController.page == 0) {
            _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
          }
        },
        borderRadius: BorderRadius.circular(30.w),
        child: AutoSizeText(
          "略過",
          style: TextStyle(
            fontSize: 16.w,
            color: ConfigColor.textColorDefault
          )
        ),
      )
    );
  }
}