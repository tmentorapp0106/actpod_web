import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/player_page/controllers/collection_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CollectButton extends ConsumerWidget {
  final CollectionController collectionController;
  final double _collectButtonWidth = 96;

  CollectButton({required this.collectionController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return buildCollectButton(ref, context);
  }

  Widget buildCollectButton(WidgetRef ref, BuildContext context) {
    if (ref.watch(isCollectedProvider) == null || ref.watch(storyInfoProvider) == null) {
      return collectLoadingButton();
    }

    if (ref.watch(isCollectedProvider)! == CollectStatus.notLogin) {
      return loginBtn(context, ref.read(storyInfoProvider)!);
    }

    if (ref.watch(isCollectedProvider)! == CollectStatus.collected) {
      return alreadyCollectedButton(ref.read(storyInfoProvider)!);
    }

    return collectBtn(ref.read(storyInfoProvider)!);
  }

  Widget collectButtonWrapper({required Widget child}) {
    return SizedBox(
      width: _collectButtonWidth,
      height: 32,
      child: child,
    );
  }

  Widget collectBtn(GetOneStoryResItem storyInfo) {
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
          padding: const EdgeInsets.symmetric(horizontal: 2),
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

  Widget loginBtn(BuildContext context, GetOneStoryResItem storyInfo) {
    return collectButtonWrapper(
      child: OutlinedButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) {
              return LoginScreen();
            }
          );
          collectionController.checkCollected(storyInfo.channelId);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: DesignColor.actpodPrimary400,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 2),
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
              "收藏",
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

  Widget alreadyCollectedButton(GetOneStoryResItem storyInfo) {
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
          padding: const EdgeInsets.symmetric(horizontal: 2),
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