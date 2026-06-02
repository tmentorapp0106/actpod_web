import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/player_controller.dart';

import '../../../config/color.dart';
import '../../../main.dart';

class FastforwardButton extends StatelessWidget {
  final PlayerController playerController;

  FastforwardButton(this.playerController);

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        playerController.fastForward();
      },
      child: SvgPicture.asset(
        "assets/icons/forward_15.svg",
        width: 32.w,
        height: 32.w,
        color: DesignColor.neutral70,
      )
    );
  }
}