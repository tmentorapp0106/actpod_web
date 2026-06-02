import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/user_info_edit_feature/controllers/edit_user_info_controller.dart';
import 'package:quick_share_app/features/user_info_edit_feature/pages/edit_bio.dart';
import 'package:quick_share_app/features/user_info_edit_feature/pages/edit_email.dart';
import 'package:quick_share_app/features/user_info_edit_feature/pages/edit_nickname.dart';
import 'package:quick_share_app/features/user_info_edit_feature/pages/edit_username.dart';
import 'package:quick_share_app/features/user_info_edit_feature/providers.dart';

class DisplayFields extends ConsumerWidget {
  final EditUserInfoController _editUserInfoController;
  final TextEditingController _nicknameTextController;
  final TextEditingController _bioTextController;
  final TextEditingController _emailTextController;

  DisplayFields(
    this._editUserInfoController,
    this._nicknameTextController,
    this._bioTextController,
    this._emailTextController
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoProvider);
    // final unionCode = ref.watch(unionCodeProvider);
    return Column(
      children: [
        nickname(context, userInfo?.nickname),
        Divider(thickness: 1.w, color: Colors.grey, height: 16.h,),
        email(context, userInfo?.email),
        Divider(thickness: 1.w, color: Colors.grey, height: 16.h,),
        bio(context, userInfo?.selfDescription),
        // Divider(thickness: 1.w, color: Colors.grey, height: 16.h,),
        // unionCodeWidget(context, unionCode)
      ],
    );
  }

  Widget nickname(BuildContext context, String? nickname) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return EditNicknamePage(
            _editUserInfoController,
            _nicknameTextController
          );
        }));
      },
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              "暱稱",
              style: TextStyle(
                color: ConfigColor.textColorDefault,
                fontSize: 18.sp
              ),
            ),
          ),
          SizedBox(
            width: 228.w,
            child: Text(
              nickname?? "",
              style: TextStyle(
                color: ConfigColor.textColorDefault,
                fontSize: 18.sp
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          ), 
          Icon(
            Icons.navigate_next_rounded,
            color: Colors.grey,
            size: 24.w,
          )
        ],
      )
    );
  }

  Widget email(BuildContext context, String? email) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return EditEmailPage(
            _editUserInfoController,
            _emailTextController
          );
        }));
      },
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              "Email",
              style: TextStyle(
                color: ConfigColor.textColorDefault,
                fontSize: 18.sp
              ),
            ),
          ),
          SizedBox(
            width: 228.w,
            child: Text(
              email?? "",
              style: TextStyle(
                color: ConfigColor.textColorDefault,
                fontSize: 18.sp
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          ), 
          Icon(
            Icons.navigate_next_rounded,
            color: Colors.grey,
            size: 24.w,
          )
        ],
      )
    );
  }

  Widget bio(BuildContext context, String? description) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return EditBioPage(
            _bioTextController,
            _editUserInfoController
          );
        }));
      },
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              "Bio",
              style: TextStyle(
                color: ConfigColor.textColorDefault,
                fontSize: 18.sp
              ),
            ),
          ),
          SizedBox(
            width: 228.w,
            child: Text(
              description?? "",
              style: TextStyle(
                color: ConfigColor.textColorDefault,
                fontSize: 18.sp
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          ), 
          Icon(
            Icons.navigate_next_rounded,
            color: Colors.grey,
            size: 24.w,
          )
        ],
      )
    );
  }

  Widget unionCodeWidget(BuildContext context, String? unionCode) {
    return Visibility(
      visible: unionCode != null,
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              "聯盟代碼",
              style: TextStyle(
                  color: ConfigColor.textColorDefault,
                  fontSize: 18.sp
              ),
            ),
          ),
          SizedBox(
            width: 228.w,
            child: SelectableText(
              unionCode?? "",
              style: TextStyle(
                color: ConfigColor.textColorDefault,
                fontSize: 18.sp
              ),
              maxLines: 1,
            )
          )
        ],
      )
    );
  }
}