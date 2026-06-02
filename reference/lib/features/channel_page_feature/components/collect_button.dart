import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/channel_page_feature/controllers/collection_controller.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';

import '../../login_feature/login_screen.dart';

class CollectButton extends ConsumerWidget {
  final String channelId;
  final CollectionController collectionController;

  CollectButton({required this.channelId, required this.collectionController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if(ref.watch(isCollectedProvider) == null) {
      return loading();
    } else if(ref.watch(isCollectedProvider)! == CollectStatus.notLogin) {
      return login(context);
    } else if(ref.watch(isCollectedProvider)! == CollectStatus.collected) {
      return already();
    } else {
      return notYet();
    }
  }

  Widget loading() {
    return const Expanded(
      child: Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: DesignColor.actpodPrimary400,
          ),
        ),
      )
    );
  }

  Widget notYet() {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          collectionController.createCollection(channelId);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: DesignColor.actpodPrimary400, // 黃底
          foregroundColor: Colors.white,                 // 文字/圖示白
          shape: const StadiumBorder(),
          side: BorderSide.none, // ✅ 無邊框
          padding: EdgeInsets.symmetric(horizontal: 18.w),
        ).copyWith(
          // ✅ 按壓/hover 的變色（像你要的按壓效果）
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withOpacity(0.05); // 按下去變深一點
            }
            return null;
          }),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.bookmark_border, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "收藏",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget login(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () async {
          await showDialog(
          context: context,
          builder: (context) {
            return LoginPageScreen();
          }
          );
          collectionController.checkCollected(channelId);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: DesignColor.actpodPrimary400, // 黃底
          foregroundColor: Colors.white,                 // 文字/圖示白
          shape: const StadiumBorder(),
          side: BorderSide.none, // ✅ 無邊框
          padding: EdgeInsets.symmetric(horizontal: 18.w),
        ).copyWith(
          // ✅ 按壓/hover 的變色（像你要的按壓效果）
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withOpacity(0.05); // 按下去變深一點
            }
            return null;
          }),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.bookmark_border, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "登入收藏",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget already() {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          collectionController.deleteCollection(channelId);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: DesignColor.actpodPrimary400,
          side: const BorderSide(color: DesignColor.actpodPrimary400, width: 1.5),
          shape: const StadiumBorder(), // ✅ 膠囊形
          // padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark, size: 20, color: DesignColor.actpodPrimary400),
            const SizedBox(width: 8),
            Text(
              "已收藏",
              style: TextStyle(
                color: DesignColor.actpodPrimary400,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5, // 讓字距像圖那樣鬆一點
              ),
            ),
          ],
        ),
      )
    );
  }
}