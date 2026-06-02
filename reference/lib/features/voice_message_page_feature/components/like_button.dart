import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/design_system/design.dart';

import '../../../config/color.dart';
import '../../../providers.dart';
import '../../../services/user_service.dart';
import '../../login_feature/login_screen.dart';
import '../controllers/likes_controller.dart';
import '../providers.dart';

class ThumbsButton extends ConsumerWidget {
  final LikesController likesController;
  final String storyId;
  final String storyOwnerId;

  ThumbsButton(this.likesController, this.storyId, this.storyOwnerId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
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
          likesController.withdrawLike(storyId);
        } else {
          likesController.like(storyId, storyOwnerId);
        }
      },
      child: Row(
        children: [
          ref.watch(likeStatusProvider)? Icon(
            Icons.favorite,
            color: DesignColor.neutral70,
            size: 18.w,
          ) : Icon(
            Icons.favorite_border_outlined,
            color: DesignColor.neutral70,
            size: 18.w,
          ),
          SizedBox(width: 2.w,),
          Text(
            ref.watch(likesCountProvider).toString(),
            style: TextStyle(
              color: DesignColor.neutral70,
              fontSize: 12.w
            ),
          )
        ]
      )
    );
  }
}