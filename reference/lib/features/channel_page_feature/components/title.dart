import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../dto/channel_dto.dart';
import '../provider.dart';

class ChannelTitle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChannelDto? channelInfo = ref.watch(channelInfoProvider);
    return Text(
      channelInfo == null? "" : channelInfo.channelName,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold
      ),
    );
  }
}