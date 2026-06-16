import 'package:actpod_web/api_manager/purchase_dto/get_user_purses.dart';
import 'package:actpod_web/api_manager/purchase_system_api_manager.dart';
import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/dto/user_info_dto.dart';
import 'package:actpod_web/features/login/provider.dart';
import 'package:actpod_web/providers.dart';
import 'package:actpod_web/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDesktop = MediaQuery.of(context).size.width >= 700;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 30.w,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 20.w),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 420 : double.infinity,
          minWidth: isDesktop ? 360 : 0,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 12 : 20.w,
            vertical: isDesktop ? 12 : 18.h,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: isDesktop ? 8 : 15.h),
                      Text(
                        "ActPod 為您締造聲音的連結",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: isDesktop ? 18 : 10.h),

                      ref.watch(loginLoadingProvider)
                          ? CircularProgressIndicator(
                              color: DesignColor.primary50,
                            )
                          : loginButton(ref, context, isDesktop),

                      SizedBox(height: isDesktop ? 4 : 8.h),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget loginButton(
    WidgetRef ref,
    BuildContext context,
    bool isDesktop,
  ) {
    return Column(
      children: [
        _LoginButton(
          isDesktop: isDesktop,
          imagePath: "assets/images/google-logo.png",
          text: "Google 登入",
          onTap: ref.watch(loginLoadingProvider)
              ? null
              : () async {
                  await _handleLogin(
                    ref,
                    context,
                    () => AuthService().signInWithGoogle(),
                  );
                },
        ),

        SizedBox(height: isDesktop ? 12 : 10.h),

        _LoginButton(
          isDesktop: isDesktop,
          imagePath: "assets/images/apple-logo.png",
          text: "Apple 登入",
          onTap: ref.watch(loginLoadingProvider)
              ? null
              : () async {
                  await _handleLogin(
                    ref,
                    context,
                    () => AuthService().signInWithApple(),
                  );
                },
        ),
      ],
    );
  }

  Future<void> _handleLogin(
    WidgetRef ref,
    BuildContext context,
    Future<UserInfoDto?> Function() loginFn,
  ) async {
    ref.read(loginLoadingProvider.notifier).state = true;

    try {
      final UserInfoDto? userInfo = await loginFn();

      if (userInfo == null) {
        return;
      }

      final GetUserPursesRes pursesRes =
          await purchaseApiManager.getUserPurses();

      ref.read(userInfoProvider.notifier).state = userInfo;

      if (pursesRes.code == "0000") {
        ref.read(userPodCoinsProvider.notifier).state =
            pursesRes.purses?.coinsPurse.podCoins ?? 0;
      }

      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      ref.read(loginLoadingProvider.notifier).state = false;
    }
  }
}

class _LoginButton extends StatelessWidget {
  final bool isDesktop;
  final String imagePath;
  final String text;
  final VoidCallback? onTap;

  const _LoginButton({
    required this.isDesktop,
    required this.imagePath,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = isDesktop ? 300 : 240.w;
    final double buttonHeight = isDesktop ? 46 : 44.h;
    final double iconSize = isDesktop ? 20 : 20.w;
    final double fontSize = isDesktop ? 16 : 16.sp;
    final double radius = isDesktop ? 22 : 20.w;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(0.35),
          ),
          borderRadius: BorderRadius.circular(radius),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
            SizedBox(width: isDesktop ? 14 : 15.w),
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}