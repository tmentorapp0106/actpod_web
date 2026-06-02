import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WithdrawTooltip extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      message: '''
提領前請留意以下事項：

1. 提領需填寫勞動報酬單，並提供相關個人資料。
2. 轉帳手續費由您自行負擔，金額將顯示於勞動報酬單中。
3. 顯示的 Podcash 為系統已扣除平台抽成後的淨額，提領時不再另行抽成。
4. 提領申請後需一定工作日處理，敬請耐心等候。
5. 若有任何問題，歡迎來信聯絡我們：contact.us@actpodapp.com
''',
      child: Icon(Icons.info_rounded, size: 18.w, color: Colors.grey),
    );
  }
}