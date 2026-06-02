import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/record_feature/providers/providers.dart';

class Feed extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "RSS feed：",
              style: TextStyle(
                  fontSize: 12.w
              ),
            )
          ],
        ),
        const SizedBox(height: 4,),
        Text(
          ref.watch(syncSettingProvider) == null? "" : ref.watch(syncSettingProvider)!.feed
        )
      ],
    );
  }
}