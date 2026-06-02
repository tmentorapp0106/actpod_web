import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/features/user_info_edit_feature/controllers/edit_user_info_controller.dart';
import 'package:quick_share_app/features/user_info_edit_feature/providers.dart';

import '../../../apiManagers/user_api_dto/get_user_info_res.dart';

class EditAvatar extends ConsumerWidget {
  final EditUserInfoController _editUserInfoController;
  
  EditAvatar(this._editUserInfoController);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);

    return Column(
      children: [
        buildUserAvatar(userInfo),
        SizedBox(height: 16.h,),
        editButton()
      ],
    );
  }

  Widget buildUserAvatar(UserInfoDto? userInfo) {
    return userInfo == null || userInfo.avatarUrl == ""?
    ClipOval(
      child: Image.asset(
        "assets/images/nullAvatar.png",
        width: 100.w,
        height: 100.w,
        fit: BoxFit.fill,
      )
    ):
    ClipOval(
      child: Image.network(
        userInfo.avatarUrl,
        width: 100.w,
        height: 100.w,
        fit: BoxFit.fitWidth,
      )
    );
  }

  Widget buildSelectedAvatar(File selectedAvatar) {
    return ClipOval(
        child: Image.file(
          selectedAvatar,
          width: 100.w,
          height: 100.w,
          fit: BoxFit.fill,
        )
    );
  }

  Widget editButton() {
    return InkWell(
      onTap: () {
        _editUserInfoController.selectNewAvatar();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        child: Text(
          "編輯頭像",
          style: TextStyle(
            color: ConfigColor.secondaryDefault,
            fontSize: 18.sp
          ),
        ),
      )
    );
  }
}