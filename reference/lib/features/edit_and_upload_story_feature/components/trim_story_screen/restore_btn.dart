import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/features/edit_and_upload_story_feature/controllers/edit_trim_player_controller.dart';
import 'package:quick_share_app/providers.dart';

import '../../../../services/toast_service.dart';
import '../../providers.dart';

class RestoreBtn extends ConsumerWidget {
  final EditTrimPlayController _playController;

  RestoreBtn(this._playController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 75.w,
      child: GestureDetector(
        onTap: () async {
          if( ref.watch(isSeekingProvider) || ref.watch(isScrollingProvider)) {
            ToastService.showNoticeToast("定位中");
            return;
          }
          if(ref.watch(playerStatusProvider) == "playing") {
            await _playController.pauseAudio();
          }
          await _playController.restoreCutStory();
        },
        child: SvgPicture.asset(
          "assets/icons/trim_page/undo.svg",
          width: 40.w,
          height: 40.w,
          fit: BoxFit.fitHeight,
        ),
      )
    );
  }
}