import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/design_system/color.dart';

import '../../../config/color.dart';
import '../../../main.dart';
import '../controllers/player_controller.dart';

class RewindButton extends StatelessWidget {
  final PlayerController playerController;

  RewindButton(this.playerController);

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: () {
        playerController.rewind();
      },
      child: SvgPicture.asset(
        "assets/icons/backward_15.svg",
        width: 32.w,
        height: 32.w,
        color: DesignColor.neutral70,
      )
    );
  }
}