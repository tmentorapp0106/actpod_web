import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quick_share_app/components/channel_image.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/design_system/design.dart';
import 'package:quick_share_app/features/home_page_feature/controllers/live_controller.dart';
import 'package:quick_share_app/router.dart';
import 'package:quick_share_app/services/toast_service.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../../live_feature/dto/purchase_ticket_enum.dart';
import '../../login_feature/login_screen.dart';
import '../providers.dart';

class LiveRoomSection extends ConsumerWidget {
  final LiveController liveController;

  LiveRoomSection({required this.liveController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms =  ref.watch(activeRoomsProvider);

    if (rooms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Podcaster 陪你一起聽",
            style: TextStyle(
              fontSize: 20.w,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8,),
          SizedBox(
            height: 148.h, // card size
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: rooms.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final room = rooms[index];

                return _LiveRoomCard(
                  imageUrl: room.storyImages[0],
                  title: room.title,
                  channelName: room.channelName,
                  channelImageUrl: room.channelImageUrl,
                  count: room.memberCount,
                  roomType: room.roomType,
                  onTap: () async {
                    if(!UserService.hasLoggedIn()) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return LoginPageScreen();
                        }
                      );
                      return ;
                    }
                    // if(UserService.getUserInfo()!.userId == room.hostId) {
                    //   ToastService.showNoticeToast("無法進入自己開的房間");
                    //   return;
                    // }
                    if(room.roomType == "interactive") {
                      if(UserService.getUserInfo()!.userId == room.hostId) {
                        await router.push(
                          "/live/interactive/host/${room.storyId}",
                          extra: {
                            "roomId": room.roomId,
                            "title": room.title.trim(),
                            "notifyFans": false,
                            "capacity": 0,
                            "notyetOwnedStoryPrice": 0,
                            "alreadyOwnedStoryPrice": 0
                          },
                        );
                      } else {
                        final result = await router.push("/live/interactive/audience/${room.roomId}/${room.storyId}");
                        if (result != null && result == PurchaseTicketEnum.notEnough) {
                          router.push("/purchase");
                        }
                      }
                    } else {
                      if(UserService.getUserInfo()!.userId == room.hostId) {
                        await router.push(
                          "/live/listen_together/host/${room.storyId}",
                          extra: {
                            "roomId": room.roomId,
                            "title": room.title.trim(),
                            "notifyFans": false,
                            "notyetOwnedStoryPrice": 0,
                            "alreadyOwnedStoryPrice": 0
                          },
                        );
                      } else {
                        final result = await router.push("/live/listen_together/audience/${room.roomId}/${room.storyId}");
                        if (result != null && result == PurchaseTicketEnum.notEnough) {
                          router.push("/purchase");
                        }
                      }
                    }
                    liveController.getLiveRooms();
                  },
                );
              },
            ),
          )
        ]
      )
    );
  }
}

class _LiveRoomCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String channelName;
  final String channelImageUrl;
  final int count;
  final String roomType;
  final VoidCallback? onTap;

  const _LiveRoomCard({
    required this.imageUrl,
    required this.title,
    required this.channelName,
    required this.channelImageUrl,
    required this.count,
    required this.roomType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 324.w,
        height: 148.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: DesignSystem.shadow,
        ),
        child:  Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverThumb(imageUrl: imageUrl),
            const SizedBox(width: 8),
            Expanded(
              child: _Info(
                title: title,
                channelName: channelName,
                channelImageUrl: channelImageUrl,
                count: count,
                roomType: roomType,
              ),
            ),
          ],
        ),
      )
    );
  }
}

class _CoverThumb extends StatelessWidget {
  final String? imageUrl;
  const _CoverThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const radius = 14.0;

    return SizedBox(
      width: 140, // 你要更大就調這個
      child: AspectRatio(
        aspectRatio: 1, // 跟你提供的圖一致
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: _CoverImage(imageUrl: imageUrl),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String title;
  final String channelName;
  final String channelImageUrl;
  final int count;
  final String roomType;

  const _Info({
    required this.title,
    required this.channelName,
    required this.channelImageUrl,
    required this.count,
    required this.roomType
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主內容（預留右下角給人數膠囊）
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 8), // 給右下 pill 空間
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // 你也可以換成品牌小圖（Image.asset / network）
                  ChannelImage(
                    channelImageUrl,
                    channelName,
                    20,
                    20,
                    radius: 2,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      channelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // 右下角：人數 pill
        Positioned(
          right: 0,
          bottom: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoomType(
                text: roomType == "listenOnly"? "陪聽" : "上麥互動",
                color: roomType == "listenOnly"? DesignColor.actpodPrimary400 : DesignColor.attention,
              ),
              const SizedBox(width: 4,),
              _CountPill(count: count)
            ],
          ),
        ),
      ],
    );
  }
}

class _RoomType extends StatelessWidget {
  final String text;
  final Color color;

  const _RoomType({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12
        ),
      )
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;
  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: DesignColor.actpodPrimary50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
              "assets/icons/boardcast.svg",
              width: 20,
              height: 20,
              fit: BoxFit.fitWidth,
              color: DesignColor.actpodPrimary500
          ),
          const SizedBox(width: 6),
          Text(
            '$count 人',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: DesignColor.actpodPrimary500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? imageUrl;

  const _CoverImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _placeholder(context);
    }

    return Container(
      color: cs.surfaceVariant.withOpacity(0.35),
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover, // ✅ 封面區通常要 cover 才像卡片封面
        errorBuilder: (_, __, ___) => _placeholder(context),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: progress.expectedTotalBytes == null
                    ? null
                    : progress.cumulativeBytesLoaded /
                    (progress.expectedTotalBytes ?? 1),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surfaceVariant.withOpacity(0.55),
      alignment: Alignment.center,
      child: Icon(
        Icons.podcasts,
        size: 28,
        color: cs.onSurfaceVariant.withOpacity(0.75),
      ),
    );
  }
}