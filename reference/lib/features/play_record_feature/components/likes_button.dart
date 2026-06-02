import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/play_record_feature/controllers/likes_controller.dart';
import 'package:quick_share_app/providers.dart';

import '../../../config/color.dart';
import '../../../main.dart';
import '../../../services/user_service.dart';
import '../../login_feature/login_screen.dart';
import '../providers.dart';

class LikesButton extends ConsumerWidget {
  final LikesController likesController;
  final PlayerItemDto storyInfo;

  LikesButton({required this.likesController, required this.storyInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        ref.watch(loadingProvider.notifier).state = false;
        if(UserService.getUserToken() == null || UserService.getUserToken() == "") {
          showDialog(
            context: context,
            builder: (context) {
              return LoginPageScreen();
            }
          );
          return;
        }

        if(ref.watch(likeStatusProvider)) {
          likesController.withdrawLike(storyInfo.storyId);
        } else {
          likesController.like(storyInfo.storyId);
        }
      },
      child: SizedBox(
        width: 65.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ref.watch(likeStatusProvider)? Icon(
              Icons.favorite,
              color: ConfigColor.primaryDefault,
              size: 24.w,
            ) : Icon(
              Icons.favorite_border_outlined,
              color: DesignColor.neutral70,
              size: 24.w,
            ),
            SizedBox(width: 2.w,),
            Text(
              ref.watch(storyStateProvider) == null? "" : ref.watch(storyStateProvider)!.likeCount.toString(),
              style: TextStyle(
                color: DesignColor.neutral70,
                fontSize: 14.w
              ),
            )
          ]
        )
      )
    );
  }
}