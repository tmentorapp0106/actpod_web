import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';

class UnionCodeDialog {
  BuildContext context;

  UnionCodeDialog(this.context);

  Future<String?> show() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _unionCodeController = TextEditingController();

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16.w), // Leave space for close icon
                    TextField(
                      controller: _unionCodeController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "請輸入聯盟代碼",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.w),
                          borderSide: BorderSide(
                            color: DesignColor.primary50, // Replace with your desired color
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 12.w),
                      ),
                    ),
                    SizedBox(height: 16.w),
                    ElevatedButton(
                      onPressed: () {
                        String enteredCode = _unionCodeController.text;
                        if (enteredCode != "") {
                          Navigator.of(context).pop(enteredCode);
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        "確認",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignColor.primary50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Close icon
              Positioned(
                right: 8.w,
                top: 8.w,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.close, size: 20.w),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}