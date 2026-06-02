import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../design_system/design.dart';

class PlayButton extends ConsumerWidget {
  final Function onTap;
  final ProviderListenable<String> provider;

  PlayButton({required this.onTap, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: DesignSystem.primary500,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(8.w),
        child: ref.watch(provider) == "playing"?
        Icon(
            Icons.pause_rounded,
            color: Colors.white,
            size: 65.w
        ) :
        Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 65.w
        ),
      )
    );
  }
}