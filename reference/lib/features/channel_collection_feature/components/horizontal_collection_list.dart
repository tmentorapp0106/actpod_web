import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/channel_image.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/channel_collection_feature/providers.dart';
import 'package:quick_share_app/router.dart';

class HorizontalCollectionList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionList = ref.watch(collectionListProvider);
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "收藏的頻道",
                  style: TextStyle(
                    fontSize: 20.w,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: () {},
              //   child: Text(
              //     '查看全部',
              //     style: TextStyle(
              //       fontSize: 12,
              //       color: DesignColor.neutral400
              //     ),
              //   ),
              // ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Horizontal list
        Visibility(
          visible:  collectionList == null,
          child: SizedBox(
            height: 84.h,
            width: ScreenUtil().screenWidth,
            child: Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: DesignColor.actpodPrimary400,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: collectionList != null,
          child: SizedBox(
            height: 84.h, // 封面 + 標題的高度
            child: collectionList != null && collectionList.isEmpty? const Center(
              child: Text(
                "沒有收藏的頻道",
                style: TextStyle(
                  color: DesignColor.neutral600
                ),
              ),
            ) : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: collectionList?.length?? 0,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final collection = collectionList![index];

                return GestureDetector(
                  onTap: () {
                    router.push("/channel/${collection.channelId}");
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ChannelImage(
                        collection.channelImageUrl,
                        collection.channelName,
                        64.w,
                        12
                      ),
                      SizedBox(height: 2.h,),
                      SizedBox(
                        width: 64.w,
                        child: Center(
                          child: Text(
                            collection.channelName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black
                            ),
                          )
                        ),
                      )
                    ],
                  )
                );
              },
            ),
          )
        ),
      ],
    );
  }
}