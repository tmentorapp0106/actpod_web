import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/live_feature/controllers/collection_controller.dart';
import 'package:quick_share_app/features/live_feature/providers.dart';

import '../../../design_system/color.dart';

class CollectButton extends ConsumerWidget {
  final CollectionController collectionController;
  final double _collectButtonWidth = 88;

  CollectButton({required this.collectionController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return buildCollectButton(ref);
  }

  Widget buildCollectButton(WidgetRef ref) {
    if (ref.watch(isCollectedProvider) == null) {
      return collectLoadingButton();
    }

    if (ref.watch(isCollectedProvider)!) {
      return alreadyCollectedButton(ref);
    }

    return collectBtn(ref);
  }

  Widget collectButtonWrapper({required Widget child}) {
    return SizedBox(
      width: _collectButtonWidth,
      child: child,
    );
  }

  Widget collectBtn(WidgetRef ref) {
    return collectButtonWrapper(
      child: OutlinedButton(
        onPressed: () {
          if(ref.read(storyInfoProvider) == null) {
            return;
          }
          collectionController.createCollection(ref.read(storyInfoProvider)!.channelId);
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

  Widget alreadyCollectedButton(WidgetRef ref) {
    return collectButtonWrapper(
      child: OutlinedButton(
        onPressed: () {
          collectionController.deleteCollection(ref.read(storyInfoProvider)!.channelId);
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