import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/providers.dart';

import '../pkg/gif.dart';

class WholePageProgress extends ConsumerStatefulWidget{
  final Widget child;
  final ProviderListenable<bool> showProvider;
  final ProviderListenable<int?> percentageProvider;
  final double? height;
  final Color? textColor;
  final String? text;

  WholePageProgress({
    super.key,
    required this.child,
    required this.showProvider,
    required this.percentageProvider,
    this.height,
    this.textColor,
    this.text,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return WholePageProgressState();
  }
}

class WholePageProgressState extends ConsumerState<WholePageProgress> with TickerProviderStateMixin {
  late final GifController _controller = GifController(vsync: this);

  @override
  Widget build(BuildContext context) {
    _controller.duration = const Duration(milliseconds: 500);

    return Stack(
      children: [
        widget.child,
        Visibility(
          visible: ref.watch(widget.showProvider),
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
                  ref.watch(loadingTextProvider) == null? const SizedBox.shrink() : Text(
                    ref.watch(loadingTextProvider)!,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: widget.textColor?? ConfigColor.textColorDefault,
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    ref.watch(widget.percentageProvider) == null? (widget.text == null? "loading..." : widget.text!) : '${ref.watch(widget.percentageProvider).toString()} %',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: widget.textColor?? ConfigColor.textColorDefault,
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