import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/whole_page_loading.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/user_info_edit_feature/providers.dart';
import 'package:quick_share_app/providers.dart';

import 'components/edit_avatar.dart';
import 'components/display_fields.dart';
import 'components/head_bar.dart';
import 'controllers/edit_user_info_controller.dart';

class UserInfoEditScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<UserInfoEditScreen> createState() {
    return UserInfoEditScreenState();
  }
}

class UserInfoEditScreenState extends ConsumerState<UserInfoEditScreen> {
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _nicknameTextController = TextEditingController();
  final TextEditingController _bioTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  EditUserInfoController? editUserInfoController;


  @override
  void initState() {
    super.initState();
    editUserInfoController = EditUserInfoController(
      ref,
      _usernameTextController,
      _nicknameTextController,
      _bioTextController,
      _emailTextController
    );
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      editUserInfoController!.getUnionCode();
      editUserInfoController!.getUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConfigColor.background,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: WholePageLoading(
          provider: loadingProvider,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h,),
                    HeadBar(editUserInfoController!),
                    SizedBox(height: 40.h,),
                    EditAvatar(editUserInfoController!),
                    SizedBox(height: 25.h,),
                    DisplayFields(
                      editUserInfoController!,
                      _nicknameTextController,
                      _bioTextController,
                      _emailTextController
                    )
                  ],
                )
              ),
            )
          )
        )
      )
    );
  }
}