import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionTerms extends StatelessWidget {
  const SubscriptionTerms({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title + Close Button
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 20, right: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '個人資料蒐集、處理及利用條款',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Divider
          Divider(height: 1, color: Colors.grey.shade300),
          // Scrollable Content
          Container(
            constraints: BoxConstraints(maxHeight: 400),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Text(
                    '''
一、會員資格
本服務僅開放註冊成為 ActPod 平台之用戶方可申請。

申請人須保證所提供之個人資料真實、完整且最新，否則 ActPod 有權隨時終止其會員資格。

二、會員方案與費用
本服務提供之會員方案、功能及收費標準，請參見 App 內所公告內容。

費用一經繳納，不可轉讓、轉售或要求退款，除非有特殊規定或法律另有要求。

三、自動續訂
若您透過 Apple App Store 或 Google Play 訂閱本服務，系統將於訂閱期間結束前自動扣款並延續服務。

若您不欲續訂，請於訂閱期限屆滿前 24 小時取消續訂，以避免自動扣款。

四、取消與終止
您可隨時取消會員方案，取消後仍可使用付費功能至目前計費週期結束。

若您違反本條款或平台使用規範，ActPod 有權不經通知即終止您的會員資格，且不另行退費。

五、服務內容變更
ActPod 保留隨時調整會員服務內容與費用結構之權利。如有變動，將於 App 內公告，不另作個別通知。

六、責任限制
ActPod 於法律允許範圍內，不對因不可抗力、系統故障、第三方因素等造成之服務中斷、延遲或損失負擔任何責任。

會員使用本服務所產生之互動內容、聲音檔案及交易，皆由使用者自負責任。

七、智慧財產權
平台所提供之所有內容（包括但不限於文字、圖片、音訊、程式碼等）皆受智慧財產權保護，未經授權不得使用、重製或公開播送。

八、準據法與管轄
本同意條款依照中華民國法律解釋與適用，若有爭議，以台灣台北地方法院為第一審管轄法院。
      ''',
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.8,
                      color: Colors.black87,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}