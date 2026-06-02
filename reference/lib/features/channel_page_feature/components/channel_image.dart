import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/dto/channel_dto.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';

class ChannelImage extends ConsumerWidget {
  final double size;
  final double borderRadius;

  ChannelImage({required this.size, required this.borderRadius});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChannelDto? channelInfo = ref.watch(channelInfoProvider);
    return SizedBox(
      width: size,
      height: size,
      child: channelInfo?.channelImageUrl == null? null : ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: CachedNetworkImage(
            imageUrl: channelInfo!.channelImageUrl,
          )
        )
      )
    );
  }
}