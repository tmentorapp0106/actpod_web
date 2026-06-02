import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/components/avatar.dart';
import 'package:quick_share_app/design_system/color.dart';

import '../../../../dto/user_info_dto.dart';
import '../controllers/list_controller.dart';
import '../provider.dart';

class SearchUserBottomSheet {
  final BuildContext context;
  final ListController _listController;
  final FocusNode _focusNode = FocusNode();

  SearchUserBottomSheet(this.context, this._listController);

  Future<UserInfoDto?> show() async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true, // helpful when keyboard shows
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.w),
        ),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              // <— make taps on empty space count
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 16.h),
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: DesignColor.neutral300,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Icon(
                              Icons.search, color: Colors.grey, size: 20.w),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: TextField(
                            focusNode: _focusNode,
                            cursorColor: Colors.black,
                            onChanged: (nickname) {
                              _listController.searchUserList(nickname);
                            },
                            decoration: InputDecoration(
                              hintText: "搜尋用戶名稱",
                              hintStyle: TextStyle(
                                  fontSize: 14.w, color: Colors.grey),
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              isDense: true,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 500.h,
                    child: ref.watch(searchUserListProvider) == null? Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 16.h), // optional spacing from top
                        child: SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            color: DesignColor.primary50,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ) : ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 8.h),
                      itemCount: ref.watch(searchUserListProvider)!.length,
                      separatorBuilder: (_, __) => Divider(height: 1),
                      itemBuilder: (context, i) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Avatar(
                            ref.watch(searchUserListProvider)![i].userId,
                            ref.watch(searchUserListProvider)![i].avatarUrl,
                            20.w,
                          ),
                          title: Text(
                            ref.watch(searchUserListProvider)![i].nickname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.of(context).pop(ref.watch(searchUserListProvider)![i]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }
}