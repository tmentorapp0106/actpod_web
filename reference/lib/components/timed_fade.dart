import 'package:flutter/material.dart';

/// Slides up from a pixel offset (e.g., imageBottom -> finalTop), holds, then fades out.
class TimedSlideFromBottomFadeOut extends StatefulWidget {
  const TimedSlideFromBottomFadeOut({
    super.key,
    required this.child,
    required this.startDyPx,   // how many pixels to travel upward from start
    this.slideIn = const Duration(milliseconds: 300),
    this.hold = const Duration(seconds: 2),
    this.fadeOut = const Duration(milliseconds: 300),
    this.curveIn = Curves.easeOut,
    this.curveOut = Curves.easeIn,
    this.onComplete,
    this.startAutomatically = true,
  });

  final Widget child;
  final double startDyPx; // positive: starts below final position and moves up by this many pixels
  final Duration slideIn;
  final Duration hold;
  final Duration fadeOut;
  final Curve curveIn;
  final Curve curveOut;
  final VoidCallback? onComplete;
  final bool startAutomatically;

  @override
  State<TimedSlideFromBottomFadeOut> createState() => _TimedSlideFromBottomFadeOutState();
}

class _TimedSlideFromBottomFadeOutState extends State<TimedSlideFromBottomFadeOut>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _dy;      // pixel translate Y
  late final Animation<double> _opacity; // fade only on the last phase

  Duration get _total => widget.slideIn + widget.hold + widget.fadeOut;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _total);

    _dy = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: widget.startDyPx, end: 0)
            .chain(CurveTween(curve: widget.curveIn)),
        weight: widget.slideIn.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: widget.hold.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: widget.fadeOut.inMilliseconds.toDouble(),
      ),
    ]).animate(_ctrl);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: (widget.slideIn + widget.hold).inMilliseconds.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: widget.curveOut)),
        weight: widget.fadeOut.inMilliseconds.toDouble(),
      ),
    ]).animate(_ctrl);

    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onComplete?.call();
    });

    if (widget.startAutomatically) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void play() => _ctrl.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _dy.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
