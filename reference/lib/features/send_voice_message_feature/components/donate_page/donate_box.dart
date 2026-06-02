import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

import '../../providers.dart';

class DonateBox extends ConsumerWidget {
  final List<int> donateAmountOptions = [0, 10, 50, 100, 1000, 9999];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: donateAmountOptions.map((coin) {
            return GestureDetector(
              onTap: () {
                ref.watch(donateAmountProvider.notifier).state = coin;
              },
              child: Container(
                width: 76.w,
                height: 40.h,
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  color: ref.watch(donateAmountProvider) == coin? ConfigColor.primaryDefault : null,
                  borderRadius: BorderRadius.circular(20),
                  border: ref.watch(donateAmountProvider) != coin? Border.all(
                    color: const Color(0xff8f8f8f)
                  ) : null
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/podcoins.png",
                        width: 20.w,
                        height: 20.w,
                        fit: BoxFit.fitWidth,
                      ),
                      Text(
                        coin.toString(),
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      )
                    ]
                  )
                ),
              )
            );
          }).toList(),
        ),
      ),
    );
  }
}