import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/design_system/components/podcoin.dart';

class PurchasePremiumStoryDialog {
  Future<String?> showInquire(
    BuildContext context, {
      required int price,
      required int balance,
    }
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '收聽專屬內容',
                      style: TextStyle(
                        fontSize: 20.w,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Podcoins 支付後，可無限期且無限次數收聽專屬內容。',
                style: TextStyle(fontSize: 14.w, color: const Color(0xFF666666)),
              ),
              const SizedBox(height: 16),

              // Price
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PodCoin(size: 28.w),
                  SizedBox(width: 4.w,),
                  Text(
                    '$price',
                    style: TextStyle(
                      fontSize: 28.w,
                      fontWeight: FontWeight.w700,
                      color: DesignColor.primary50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Balance
              Row(
                children: [
                  PodCoin(size: 16.w),
                  const SizedBox(width: 6),
                  Text(
                    '擁有 Podcoin：$balance',
                    style:  TextStyle(fontSize: 12.w, color: Color(0xFF757575)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Pay button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if(balance >= price) {
                      Navigator.of(context).pop("pay");
                    } else {
                      Navigator.of(context).pop("purchase");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColor.primary50,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                    disabledForegroundColor: const Color(0xFF9E9E9E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    balance >= price? '支付 Podcoins' : 'Podcoins 不足請先購買',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> showConfirm(
    BuildContext context, {
      required int price,
      required int balance,
    }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 60.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '支付 Podcoins',
                      style: TextStyle(fontSize: 20.w, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    iconSize: 18,
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Center(
                child: Text(
                  '確定支付 $price Podcoins 嗎？',
                  style: TextStyle(fontSize: 14.w, color: Colors.grey),
                ),
              ),
              SizedBox(height: 16.h),

              // Balance row
              Row(
                children: [
                  PodCoin(size: 16.w),
                  const SizedBox(width: 6),
                  Text(
                    '擁有 Podcoin：$balance',
                    style: TextStyle(fontSize: 12.w, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Confirm
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 32.h,
                    width: 100.w,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: DesignColor.primary50, width: 1.4),
                        foregroundColor: DesignColor.primary50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('取消', style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(
                    height: 32.h,
                    width: 100.w,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignColor.primary50,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFE5E5E5),
                        disabledForegroundColor: const Color(0xFF9E9E9E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('確定', style: TextStyle(fontSize: 14.w, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}