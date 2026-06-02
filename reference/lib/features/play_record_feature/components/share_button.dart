import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/features/play_record_feature/providers.dart';
import 'package:share_plus/share_plus.dart';


class ShareButton extends ConsumerWidget {
  final PlayerItemDto storyInfo;

  ShareButton({required this.storyInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(showShareLinkProvider),
      child: InkWell(
        borderRadius: BorderRadius.circular(25.w),
        onTap: () async {
          final box = context.findRenderObject() as RenderBox?;
          SharePlus.instance.share(
            ShareParams(
              text: 'https://web.actpodapp.com/story/${storyInfo.storyId}?openExternalBrowser=1',
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size
            )
          );
        },
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Icon(
            Icons.share_rounded,
            size: 20.w,
            color: Colors.black
          )
        ),
      )
    );
  }
}