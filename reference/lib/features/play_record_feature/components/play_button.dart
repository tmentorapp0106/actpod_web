import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/apiManagers/story_api_dto/buy_premium_story.dart';
import 'package:quick_share_app/apiManagers/story_system_api_manager.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/play_record_feature/components/purchase_premium_story_dialog.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../../design_system/components/podcoin.dart';
import '../../../main.dart';
import '../../../router.dart';
import '../../login_feature/login_screen.dart';
import '../controllers/player_controller.dart';
import '../providers.dart';

enum PlayerIconStatus {
  processing,
  play,
  pause,
  premium
}

class PlayButton extends ConsumerWidget {
  final PlayerController playerController;
  final PlayerItemDto storyInfo;

  PlayButton(this.playerController, this.storyInfo);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(mainPlayerStatusProvider);
    PlayerIconStatus playerIconStatus = PlayerIconStatus.processing;
    Widget icon;
    if(storyInfo.storyId == actPodAudioHandler?.mediaItem.value?.id) {
      if(playerState == MainPlayerState.playing) {
        playerIconStatus = PlayerIconStatus.pause;
        icon = Icon(
          Icons.pause_rounded,
          size: 36.w,
          color: Colors.white,
        );
      } else if (playerState == MainPlayerState.paused) {
        playerIconStatus = PlayerIconStatus.play;
        icon = Icon(
          Icons.play_arrow_rounded,
          size: 36.w,
          color: Colors.white,
        );
      } else {
        playerIconStatus = PlayerIconStatus.processing;
        icon = Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white,
            )
        );
      }
    } else {
      if(ref.watch(loadingPlayerStoryInfoProvider)?.storyId == storyInfo.storyId && (ref.watch(mainPlayerStatusProvider) == MainPlayerState.loading || ref.watch(mainPlayerStatusProvider) == MainPlayerState.initiating)) {
        playerIconStatus = PlayerIconStatus.processing;
        icon = Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.white,
          )
        );
      } else {
        if(storyInfo.isPremium) {
          if(ref.watch(premiumStatusProvider) == null) {
            playerIconStatus = PlayerIconStatus.processing;
            icon = Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              )
            );
          } else if(ref.watch(premiumStatusProvider) == PremiumStatus.unpaid) {
            playerIconStatus = PlayerIconStatus.premium;
            icon = PodCoin(
              size: 40.w,
            );
          } else {
            playerIconStatus = PlayerIconStatus.play;
            icon = Icon(
              Icons.play_arrow_rounded,
              size: 36.w,
              color: Colors.white,
            );
          }
        } else {
          playerIconStatus = PlayerIconStatus.play;
          icon = Icon(
            Icons.play_arrow_rounded,
            size: 36.w,
            color: Colors.white,
          );
        }
      }
    }
    return GestureDetector(
      onTap: () async {
        if(playerIconStatus == PlayerIconStatus.processing) {
          return;
        } else if(playerIconStatus == PlayerIconStatus.premium) {
          if (!UserService.hasLoggedIn()) {
            showDialog(
              context: context,
              builder: (context) {
                return LoginPageScreen();
              }
            );
            return;
          }

          final balance = ref.watch(userPodCoinsProvider);
          ref.watch(premiumStatusProvider.notifier).state = null;
          String? action = await PurchasePremiumStoryDialog().showInquire(
              context, price: storyInfo.price, balance: balance);
          if (action == null) {
            playerController.checkPaid(storyInfo);
            return;
          }
          if (action == "purchase") {
            router.push("/purchase");
            playerController.checkPaid(storyInfo);
            return;
          }

          if (!context.mounted) {
            return;
          }

          bool? confirm = await PurchasePremiumStoryDialog().showConfirm(
              context, price: storyInfo.price, balance: balance);
          if (confirm == null || !confirm) {
            playerController.checkPaid(storyInfo);
            return;
          }

          ref.watch(mainPlayerStatusProvider.notifier)
              .state = MainPlayerState.loading;
          BuyPremiumStoryRes buyRes = await storyApiManager.buyPremiumStory(
              storyInfo.storyId);
          if (buyRes.code != "0000") {
            ToastService.showNoticeToast("購買失敗");
            playerController.checkPaid(storyInfo);
            return;
          }

          UserService.reloadUserPurses(ref);
          playerController.checkPaid(storyInfo);
          return;
        } else if(playerIconStatus == PlayerIconStatus.play) {
          if(actPodAudioHandler?.mediaItem.value?.id != storyInfo.storyId) {
            playerController.initNewPlayItemList(storyInfo, true);
            return;
          } else {
            actPodAudioHandler?.play();
          }
        } else {
          actPodAudioHandler?.pause();
        }
      },
      child: Container(
        width: 48.w, // adjust size as needed
        height: 48.w,
        decoration: BoxDecoration(
          color: DesignColor.primary50, // or Color(0xFFFFC107) for consistent yellow
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
    );
  }
}