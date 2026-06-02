import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';

import '../pkg/gif.dart';

class PartialPageLoading extends ConsumerStatefulWidget{
  final Widget child;
  final double height;
  final ProviderListenable<bool> provider;
  final double? gifHeight;
  final double? gifWidth;
  final bool showText;

  PartialPageLoading({
    super.key,
    required this.child,
    required this.height,
    required this.provider,
    this.gifHeight,
    this.gifWidth,
    this.showText = true
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return PartialPageLoadingState();
  }
}

class PartialPageLoadingState extends ConsumerState<PartialPageLoading> with TickerProviderStateMixin {
  late final GifController _controller = GifController(vsync: this);

  @override
  dispose() {
    _controller.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.duration = const Duration(milliseconds: 500);

    return Stack(
      children: [
        widget.child,
        Visibility(
          visible: ref.watch(widget.provider),
          maintainState: true,
          child: SizedBox(
            height: widget.height,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      width: widget.gifWidth ?? 100.w,
                      height: widget.gifHeight ?? 70.h,
                      child: Gif(
                        image: const AssetImage("assets/icons/partial_loading.gif"),
                        autostart: Autostart.loop,
                        duration: const Duration(milliseconds: 500),
                        onFetchCompleted: () {
                          _controller.forward();
                        },
                      )
                  ),
                  widget.showText? Text(
                    'Loading...',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: ConfigColor.textColorDefault,
                      fontSize: 12.sp,
                    ),
                  ) : const SizedBox.shrink(),
                ]
              )
            )
          )
        )
      ]
    );
  }
}