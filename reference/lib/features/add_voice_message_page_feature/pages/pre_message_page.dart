import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/components/pre_message_page/skip_button.dart';
import 'package:quick_share_app/features/add_voice_message_page_feature/controllers/pre_message_recorder_controller.dart';
import '../components/pre_message_page/description.dart';
import '../components/pre_message_page/hint_bar.dart';
import '../components/pre_message_page/button_set.dart';
import '../components/pre_message_page/timer.dart';
import '../components/pre_message_page/title.dart';
import '../components/pre_message_page/wave_forms.dart';

class PreMessagePage extends ConsumerWidget {
  final PreMessageRecorderController _preMessageRecorderController;
  final PageController _pageViewController;

  PreMessagePage(this._preMessageRecorderController, this._pageViewController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PreMessageTitle(),
        PreMessageDescription(),
        HintBar(),
        WaveForms(_preMessageRecorderController),
        Timer(),
        SizedBox(height: 5.h,),
        ButtonSet(_preMessageRecorderController, _pageViewController),
        SizedBox(height: 15.h,),
        SkipBtn(_pageViewController),
        SizedBox(height: 10.h,),
      ]
    );
  }
}