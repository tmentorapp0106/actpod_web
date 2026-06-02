import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/providers.dart';

import '../pkg/gif.dart';

class WholePageLoading extends ConsumerStatefulWidget{
  final Widget child;
  final ProviderListenable<bool> provider;
  final double? height;

  WholePageLoading({
    super.key,
    required this.child,
    required this.provider,
    this.height
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return WholePageLoadingState();
  }
}

class WholePageLoadingState extends ConsumerState<WholePageLoading> with TickerProviderStateMixin {
  late final GifController _controller = GifController(vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.duration = const Duration(milliseconds: 500);

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: ref.watch(widget.provider),
          child: widget.child,
        ),
        Visibility(
          visible: ref.watch(widget.provider),
          maintainState: true,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            height: widget.height,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 180.w,
                    height: 130.h,
                    child: Gif(
                      image: const AssetImage("assets/icons/loading.gif"),
                      autostart: Autostart.loop,
                      duration: const Duration(milliseconds: 500),
                      onFetchCompleted: () {
                        _controller.forward();
                      },
                    )
                  ),
                  Text(
                    ref.watch(loadingTextProvider)?? 'Loading...',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: ConfigColor.textColorDefault,
                      fontSize: 18.sp,
                    ),
                  ),
                ]
              )
            )
          )
        )
      ]
    );
  }
}