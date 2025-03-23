import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers.dart';


class LikesButton extends ConsumerWidget {
  LikesButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
      },
      child: Row(
        children: [
          Icon(
            Icons.favorite_border_outlined,
            color: Colors.grey,
            size: 18.w,
          ),
          SizedBox(width: 2.w,),
          Text(
            ref.watch(likesCountProvider).toString(),
            style: TextStyle(
              color: Colors.black,
              fontSize: 12.w
            ),
          )
        ]
      )
    );
  }
}