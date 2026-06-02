import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';

class StepperNav extends StatelessWidget {
  final int currentStep;

  const StepperNav({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {"label": "編輯故事"},
      {"label": "擷取精華"},
      {"label": "上傳設定"},
      {"label": "預覽畫面"},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length * 2 - 1, (index) {
          final stepIndex = index ~/ 2;
          if (index.isOdd) {
            // connector line
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.w / 2 + 12.w / 2 + 2), // calculate center position
                child: Container(
                  height: 2,
                  color: stepIndex < currentStep ? DesignColor.primary80 : Colors.grey.shade400
                ),
              ),
            );
          }

          final isCompleted = stepIndex < currentStep;
          final isCurrentStep = stepIndex == currentStep;

          Widget icon;
          if(isCurrentStep) {
            icon = Container(
              width: 24.w,
              height: 24.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // or Colors.transparent
                border: Border.all(color: DesignColor.primary80, width: 2),
              ),
              child: Icon(
                Icons.more_horiz_rounded,
                size: 16,
                color: DesignColor.primary80,
              ),
            );
          } else if(isCompleted) {
            icon = Container(
              width: 24.w,
              height: 24.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignColor.primary80,
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
            );
          } else {
            icon = Container(
              width: 24.w,
              height: 24.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // or Colors.transparent
                border: Border.all(color: Colors.grey, width: 2),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 24.w,
                child: Center(
                  child: icon
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex]["label"] as String,
                style: TextStyle(
                  fontSize: 12.w,
                  fontWeight: isCompleted || isCurrentStep ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted || isCurrentStep ? DesignColor.primary80 : Colors.grey,
                ),
              ),
            ],
          );
        }),
      )
    );
  }
}