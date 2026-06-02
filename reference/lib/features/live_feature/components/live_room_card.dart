import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../components/channel_image.dart';
import '../../../design_system/color.dart';
import '../../../design_system/design.dart';

class LiveRoomCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String channelName;
  final String channelImageUrl;
  final int count;
  final String roomType; 
  final VoidCallback? onTap;

  const LiveRoomCard({
    super.key,
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
        height: 148,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: DesignSystem.shadow,
        ),
        child: Row(
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
      ),
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