import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/features/user_info_feature/providers.dart';
import 'package:quick_share_app/local_storage/repositories/story_recommendation_repository.dart';
import 'package:quick_share_app/services/clean_service.dart';
import 'package:quick_share_app/services/env_service.dart';
import 'package:quick_share_app/services/language_service.dart';
import 'package:quick_share_app/shared_prefs/server_prefs.dart';

import '../../../config/color.dart';
import '../../../main.dart';
import '../../../providers.dart';
import '../../../services/user_service.dart';
import '../../login_feature/login_screen.dart';

class SelectRegionPage extends ConsumerWidget {
  const SelectRegionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(regionSelectionProvider);

    return WholePageLoading(
      provider: loadingProvider,
      child: Scaffold(
        backgroundColor: ConfigColor.background,
        appBar: AppBar(
          backgroundColor: ConfigColor.background,
          title: const Text('Change Region'),
        ),
        body: Column(
          children: [
            optionAsia(region, ref),
            optionUSA(region, ref),
            SizedBox(height: 30.h,),
            changeButton(region, context, ref)
          ],
        ),
      )
    );
  }

  Widget changeButton(String region, BuildContext context, WidgetRef ref) {
    return Material(
      borderRadius: BorderRadius.circular(10.w),
      color: ConfigColor.primaryDefault,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.w),
        onTap: () async {
          ref.watch(loadingProvider.notifier).state = true;
          if(UserService.getUserToken() != null && UserService.getUserToken() != "") {
            await UserService.logoutUser(ref);
          }
          CleanService.cleanLocalStorage();
          await ServerPrefs.setServerByServerName(region);
          await EnvService.load();
          Navigator.of(context).pop();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 50.w),
          child: Text(
            "Change",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold
            ),
          )
        )
      )
    );
  }

  Widget optionAsia(String selectedRegion, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.watch(regionSelectionProvider.notifier).state = ServerOption.Asia.name;
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 20.w,
              width: 20.w,
              decoration: BoxDecoration(
                border: Border.all(
                    width: selectedRegion == ServerOption.Asia.name? 5.w : 1.w,
                    color: selectedRegion == ServerOption.Asia.name? ConfigColor.primaryDefault : ConfigColor.textColorDefault
                ),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 20.w,),
            Text(
              "Asia",
              style: TextStyle(
                color: ConfigColor.textColorDefault,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        )
      )
    );
  }

  Widget optionUSA(String selectedRegion, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.watch(regionSelectionProvider.notifier).state = ServerOption.USA.name;
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 20.w,
              width: 20.w,
              decoration: BoxDecoration(
                border: Border.all(
                    width: selectedRegion == ServerOption.USA.name? 5.w : 1.w,
                    color: selectedRegion == ServerOption.USA.name? ConfigColor.primaryDefault : ConfigColor.textColorDefault
                ),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 20.w,),
            Text(
              "USA",
              style: TextStyle(
                color: ConfigColor.textColorDefault,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        )
      )
    );
  }
}