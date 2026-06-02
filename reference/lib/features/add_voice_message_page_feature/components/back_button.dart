import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/providers.dart';

class AddVoiceMessageBackButton extends ConsumerWidget {
  final PageController _pageViewController;

  AddVoiceMessageBackButton(this._pageViewController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(pagePositionProvider) == 1,
      child: InkWell(
        onTap: () {
          _pageViewController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
        },
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Icon(
            Icons.arrow_back_ios,
            size: 25.w,
          )
        )
      )
    );
  }
}