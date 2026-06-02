import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers.dart';

class PageTitle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Text(
          ref.watch(searchStoriesItemListProvider) == null &&
              ref.watch(searchUserItemListProvider) == null &&
            ref.watch(searchChannelItemListProvider) == null? "空間列表" : "搜尋結果",
          style: TextStyle(color: Colors.black, fontSize: 18.w, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}