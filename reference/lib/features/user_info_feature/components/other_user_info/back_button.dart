import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_share_app/router.dart';

import '../../../../services/page_router_service.dart';
import '../../providers.dart';

class UserInfoBackButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        router.pop();
      },
      child: Icon(
        Icons.arrow_back_ios,
        size: 24.w,
      ),
    );
  }
}