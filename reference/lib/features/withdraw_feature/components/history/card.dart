import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/dto/withdraw_dto.dart';
import 'package:quick_share_app/features/withdraw_feature/pages/update_withdraw_info.dart';
import 'package:quick_share_app/utils/time_utils.dart';

import '../../controllers/withdraw_controller.dart';

class WithdrawCard extends StatelessWidget {
  final WithdrawDto withdraw;
  final TextEditingController emailEditingController;
  final TextEditingController phoneEditingController;
  final WithdrawController withdrawController;

  const WithdrawCard({
    Key? key,
    required this.withdraw,
    required this.emailEditingController,
    required this.phoneEditingController,
    required this.withdrawController
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    if(withdraw.status == "Pending") {
      statusColor = Color(0xffe7e7e7);
      statusText = "已申請，待處理";
    } else if(withdraw.status == "Completed") {
      statusColor = Color(0xffbfded4);
      statusText = "已轉帳";
    } else {
      statusColor = Color(0xfffff0ce);
      statusText = "處理中";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TimeUtils.convertToFormat("yyyy/MM/dd", withdraw.createTime), 
            style: TextStyle(
              fontSize: 20.w,
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(fontSize: 12.w, color: Colors.black),
            ),
          ),
          const SizedBox(height: 12),
          Text('Podcash 金額：${withdraw.podcash}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.w, color: Colors.black)),
          const SizedBox(height: 8),
          Text('轉帳日期：${withdraw.transferTime == null? "待處理完成" : TimeUtils.convertToFormat("yyyy/MM/dd", withdraw.transferTime!)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.w, color: Colors.black)),
          const SizedBox(height: 8),
          Visibility(
            visible: withdraw.status != "Completed",
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  emailEditingController.text = withdraw.email;
                  phoneEditingController.text = withdraw.phone;
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UpdateWithdrawInfoPage(
                      withdraw.withdrawId,
                      emailEditingController,
                      phoneEditingController,
                      withdrawController
                    ),
                  ));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      '修改提領資訊',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ],
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}