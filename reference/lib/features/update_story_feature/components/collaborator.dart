import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/update_story_feature/components/search_user_bottom_sheet.dart';
import 'package:quick_share_app/features/update_story_feature/controllers/list_controller.dart';

import '../../../components/avatar.dart';
import '../../../config/color.dart';
import '../../../dto/user_info_dto.dart';
import '../../../utils/string_utils.dart';
import '../provider.dart';

class Collaborator extends ConsumerWidget {
  final ListController listController;

  Collaborator({required this.listController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "合作創作者",
                  style: TextStyle(
                    color: ConfigColor.textColorDefault,
                    fontSize: 16.w,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "此創作者也可回覆聽眾留言",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.w,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ]
                ),
              ],
            ),
            const Spacer(),
            Visibility(
              visible: ref.watch(collaboratorProvider) == null,
              child: GestureDetector(
                onTap: () async {
                  UserInfoDto? selected = await SearchUserBottomSheet(context, listController).show();
                  if(selected != null) {
                    ref.watch(collaboratorProvider.notifier).state = selected;
                  }
                },
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  size: 32.w,
                  color: Colors.black,
                )
              )
            )
          ]
        ),
        SizedBox(height: 8.h,),
        ref.watch(collaboratorProvider) == null? const SizedBox.shrink() : Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.grey
              ),
              borderRadius: BorderRadius.circular(8)
          ),
          child: Row(
            children: [
              Avatar(
                ref.watch(collaboratorProvider)!.userId,
                ref.watch(collaboratorProvider)!.avatarUrl,
                20.w
              ),
              SizedBox(width: 8.w,),
              Text(
                StringUtils.shorten(ref.watch(collaboratorProvider)!.nickname, 15),
                style: TextStyle(
                    fontSize: 14.w,
                    color: Colors.black
                ),
              ),
              const Spacer(),
              GestureDetector(
                  onTap: () {
                    ref.watch(collaboratorProvider.notifier).state = null;
                  },
                  child: Icon(
                      Icons.close,
                      size: 20.w,
                      color: Colors.black
                  )
              )
            ],
          ),
        )
      ],
    );
  }
}