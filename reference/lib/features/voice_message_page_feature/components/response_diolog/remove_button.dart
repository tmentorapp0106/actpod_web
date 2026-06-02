import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../controllers/record_controller.dart';

class RemoveButton extends ConsumerWidget{
  final RecordController _recordController;

  RemoveButton(this._recordController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Center(
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              _recordController.stopAudio();
              _recordController.resetRecording();
            },
            child: SvgPicture.asset(
              "assets/icons/deleteStoryImg.svg",
              color: Colors.black,
              width: 18.w,
              height: 18.w,
            ),
          ),
        ),
        Text(
          "刪除",
          style: TextStyle(
            fontSize: 12.w
          ),
        )
      ]
    );
  }
}