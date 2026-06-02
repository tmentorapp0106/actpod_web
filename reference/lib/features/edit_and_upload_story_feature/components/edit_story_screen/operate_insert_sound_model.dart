import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../dto/block_info_dto.dart';
import '../../controllers/edit_trim_player_controller.dart';
import '../../providers.dart';

class OperateInsertSoundModel extends ConsumerWidget {
  final int blockIndex;
  final EditTrimPlayController _playController;

  OperateInsertSoundModel(this.blockIndex, this._playController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 3.h,
                  width: 50.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.w),
                    color: Colors.grey
                  ),
                )
              ]
            ),
            SizedBox(height: 10.h,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                "編輯",
                style: TextStyle(
                  fontSize: 16.w,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              )
            ),
            Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 75.h),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          List<BlockInfoDto> tracks = ref.watch(blockInfosProvider);
                          _playController.removeSound(blockIndex, tracks[blockIndex]);
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.delete_forever_rounded,
                          size: 45.w,
                          color: Colors.white,
                        )
                      ),
                      Text(
                        "移除",
                        style: TextStyle(
                            fontSize: 12.w,
                            color: Colors.white
                        ),
                      )
                    ],
                  ),
                )
            )
          ],
        )
    );
  }
}