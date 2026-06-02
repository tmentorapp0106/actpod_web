import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/color.dart';
import '../../providers.dart';

class RoomTitle extends ConsumerWidget {
  const RoomTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomInfo = ref.watch(roomInfoProvider);

    if (roomInfo == null) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: DesignColor.actpodPrimary500,
        ),
      );
    }

    return SizedBox(
      height: 24, // 固定高度，避免 layout 跳動
      width: 300,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            roomInfo.title,
            softWrap: false, // 單行
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}