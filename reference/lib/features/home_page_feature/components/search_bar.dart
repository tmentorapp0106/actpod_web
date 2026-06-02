import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../l10n/app_localizations.dart';

import '../../../providers.dart';

class SearchContentBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(
          color: Colors.black
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: ref.watch(localeProvider) == const Locale('zh')? 4.5.h : 0),
            child: Icon(
              Icons.search,
              color: Colors.grey,
              size: 25.w,
            )
          ),
          SizedBox(width: 2.w,),
          Expanded(
            child: TextField(
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchStoryName,
                hintStyle: TextStyle(
                  fontSize: 18.w,
                  color: Colors.grey
                ),
                contentPadding: EdgeInsets.all(0.h),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none
                ),
                isDense: true,
                isCollapsed: true
              ),
            )
          )
        ],
      )
    );
  }
}