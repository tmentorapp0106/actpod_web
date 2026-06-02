import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/components/podcoin.dart';

import '../../../design_system/color.dart';
import '../dto/purchase_ticket_enum.dart';

class TicketDialog {
  Future<PurchaseTicketEnum?> showPaidLiveRoomDialog({
    required BuildContext context,
    required int requiredPodcoins,
    required int currentPodcoins,
  }) {
    final bool hasEnoughPodcoins = currentPodcoins >= requiredPodcoins;
    final int shortage = requiredPodcoins - currentPodcoins;

    return showDialog<PurchaseTicketEnum?>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: DesignColor.actpodPrimary100,
                    shape: BoxShape.circle,
                  ),
                  child: PodCoin(size: 32)
                ),

                SizedBox(height: 16.h),

                Text(
                  "確認進入付費直播",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: DesignColor.actpodPrimary950,
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  "進入此直播房需要支付 Podcoins",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 18.h),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: DesignColor.actpodPrimary100.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: DesignColor.actpodPrimary400.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      _podcoinInfoRow(
                        title: "需要支付",
                        value: "$requiredPodcoins Podcoins",
                        valueColor: DesignColor.actpodPrimary500,
                      ),

                      SizedBox(height: 10.h),

                      _podcoinInfoRow(
                        title: "目前擁有",
                        value: "$currentPodcoins Podcoins",
                        valueColor: hasEnoughPodcoins
                            ? DesignColor.actpodPrimary950
                            : Colors.redAccent,
                      ),

                      if (!hasEnoughPodcoins) ...[
                        SizedBox(height: 10.h),
                        Divider(
                          height: 1,
                          color: DesignColor.actpodPrimary400.withOpacity(0.35),
                        ),
                        SizedBox(height: 10.h),
                        _podcoinInfoRow(
                          title: "尚缺",
                          value: "$shortage Podcoins",
                          valueColor: Colors.redAccent,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(PurchaseTicketEnum.cancel);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          "取消",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 10.w),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(hasEnoughPodcoins? PurchaseTicketEnum.purchase : PurchaseTicketEnum.notEnough);
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: DesignColor.actpodPrimary500,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          hasEnoughPodcoins ? "支付" : "前去儲值",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _podcoinInfoRow({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        const SizedBox(width: 4,),
        PodCoin(size: 16,)
      ],
    );
  }
}