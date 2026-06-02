import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/channel_page_feature/controllers/channel_controller.dart';

import '../../../../components/avatar.dart';
import '../../../../config/color.dart';
import '../../../../dto/user_info_dto.dart';
import 'search_user_bottom_sheet.dart';
import '../../../../utils/string_utils.dart';
import '../../provider.dart';

class ChannelCoOwners extends ConsumerWidget {
  final ChannelController channelController;

  const ChannelCoOwners({
    super.key,
    required this.channelController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coOwners = ref.watch(channelCoOwnersProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "共同擁有者",
                    style: TextStyle(
                      color: ConfigColor.textColorDefault,
                      fontSize: 16.w,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "共同擁有者也可以管理此頻道",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  UserInfoDto? selected =
                  await SearchUserBottomSheet(context, channelController).show();

                  if (selected == null) {
                    return;
                  }

                  final alreadyExists = coOwners.any(
                        (user) => user.userId == selected.userId,
                  );

                  if (alreadyExists) {
                    return;
                  }

                  ref.read(channelCoOwnersProvider.notifier).state = [
                    ...coOwners,
                    selected,
                  ];
                },
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 32.w,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          if (coOwners.isNotEmpty)
            Column(
              children: coOwners.map((user) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Avatar(
                          user.userId,
                          user.avatarUrl,
                          20.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          StringUtils.shorten(user.nickname, 15),
                          style: TextStyle(
                            fontSize: 14.w,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            ref.read(channelCoOwnersProvider.notifier).state =
                              coOwners
                                  .where((u) => u.userId != user.userId)
                                  .toList();
                          },
                          child: Icon(
                            Icons.close,
                            size: 20.w,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}