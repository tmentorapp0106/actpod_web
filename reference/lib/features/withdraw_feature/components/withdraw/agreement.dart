import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/features/withdraw_feature/providers.dart';

class WithdrawAgreement extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StatefulBuilder(
      builder: (context, setState) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          height: 500,
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              // Title and close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('提領 Podcash 條款同意書', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.w)),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Text('''
請您在申請提領 Podcash 前，務必詳細閱讀以下條款內容，並確認您已完全理解與同意本條款所載之所有內容：

一、申請資格
  1. 申請人須為已註冊之 ActPod 平台創作者，且其帳戶須完成真實身份驗證。
  2. 僅限付費會員可進行 Podcash 提領，免費會員僅可累積，不得申請提領。

二、提領流程
  1. 提領申請需經平台審核，預計處理時間為 3–5 個工作天（不含例假日）。
  2. 經審核通過後，款項將轉入您所提供之銀行帳戶或指定支付工具。
  3. 每月提領次數上限為 1 次，如需額外提領須經平台審核許可。

三、手續費與稅務
  1. 提領將自動扣除必要平台服務費與稅額（如適用），明細將顯示於提領記錄中。
  2. 您應自行確認與報繳相關所得稅，平台不負代扣代繳責任。

四、異常與爭議
  1. 若提領資料填寫錯誤導致款項退回，將酌收處理費用。
  2. 如發現違反平台規範（如洗錢、詐欺等），ActPod 有權凍結帳戶並拒絕提領。

五、條款修改
ActPod 有權於不另行通知下修改本條款，修改後之內容將公告於平台，您續行使用平台或再次申請提領即視為同意最新版本條款。

如您已閱讀並同意上述條款，請勾選同意框並繼續提領流程。若有疑問，請聯繫客服信箱：contact.us@actpodapp.com。
'''),
                ),
              ),
              const SizedBox(height: 8),
              // Checkbox
              Row(
                children: [
                  Checkbox(
                    value: ref.watch(withdrawReadProvider),
                    activeColor: ConfigColor.primaryDefault,
                    onChanged: (val) => ref.watch(withdrawReadProvider.notifier).state = val ?? false,
                  ),
                  Expanded(child: Text('我已閱讀完提領條款同意書')),
                ],
              ),
              const SizedBox(height: 8),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.watch(withdrawAgreementProvider.notifier).state = false;
                        Navigator.of(context).pop();
                      },
                      child: Text('不同意'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: ref.watch(withdrawReadProvider)? (){
                        ref.watch(withdrawAgreementProvider.notifier).state = true;
                        Navigator.of(context).pop();
                       } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ConfigColor.primaryDefault,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Color(0xffe7e7e7),
                      ),
                      child: Text('同意'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}