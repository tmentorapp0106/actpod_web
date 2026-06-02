import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/color.dart';
import '../../../dto/player_item_dto.dart';
import '../../login_feature/login_screen.dart';
import '../controllers/collection_controller.dart';
import '../providers.dart';

class CollectButton extends ConsumerWidget {
  final CollectionController collectionController;
  final PlayerItemDto storyInfo;
  final double _collectButtonWidth = 96;

  CollectButton({required this.collectionController, required this.storyInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return buildCollectButton(ref, context);
  }

  Widget buildCollectButton(WidgetRef ref, BuildContext context) {
    if (ref.watch(isCollectedProvider) == null) {
      return collectLoadingButton();
    }

    if (ref.watch(isCollectedProvider)! == CollectStatus.notLogin) {
      return loginBtn(ref, context);
    }

    if (ref.watch(isCollectedProvider)! == CollectStatus.collected) {
      return alreadyCollectedButton(ref);
    }

    return collectBtn(ref);
  }

  Widget collectButtonWrapper({required Widget child}) {
    return SizedBox(
      width: _collectButtonWidth,
      height: 36,
      child: child,
    );
  }

  Widget collectBtn(WidgetRef ref) {
    return collectButtonWrapper(
      child: OutlinedButton(
        onPressed: () {
          collectionController.createCollection(storyInfo.channelId);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: DesignColor.actpodPrimary400,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 6),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withOpacity(0.05);
            }
            return null;
          }),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.bookmark_border, size: 16, color: Colors.white),
            SizedBox(width: 2),
            Text(
              "收藏",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget loginBtn(WidgetRef ref, BuildContext context) {
    return collectButtonWrapper(
      child: OutlinedButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) {
              return LoginPageScreen();
            }
          );
          collectionController.checkCollected(storyInfo.channelId);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: DesignColor.actpodPrimary400,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 6),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withOpacity(0.05);
            }
            return null;
          }),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 16, color: Colors.white),
            SizedBox(width: 2),
            Text(
              "登入收藏",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget alreadyCollectedButton(WidgetRef ref) {
    return collectButtonWrapper(
      child: OutlinedButton(
        onPressed: () {
          collectionController.deleteCollection(storyInfo.channelId);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: DesignColor.actpodPrimary400,
          side: const BorderSide(
            color: DesignColor.actpodPrimary400,
            width: 1.5,
          ),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          elevation: 0,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withOpacity(0.05);
            }
            return null;
          }),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 16,
              color: DesignColor.actpodPrimary400,
            ),
            SizedBox(width: 2),
            Text(
              "已收藏",
              style: TextStyle(
                color: DesignColor.actpodPrimary400,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget collectLoadingButton() {
    return collectButtonWrapper(
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          backgroundColor: DesignColor.actpodPrimary400.withOpacity(0.7),
          disabledBackgroundColor: DesignColor.actpodPrimary400.withOpacity(0.7),
          disabledForegroundColor: Colors.white,
          shape: const StadiumBorder(),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 6),
        ),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}