import 'dart:async';
import 'package:flutter/material.dart';

class LongPressDetector extends StatefulWidget {
  final Function onLongPressDown;
  final Function onLongPressUp;
  final Duration duration;
  final Widget child;

  LongPressDetector({
    super.key,
    required this.onLongPressDown,
    required this.onLongPressUp,
    required this.duration,
    required this.child
  });

  @override
  State<StatefulWidget> createState() {
    return LongPressDetectorState();
  }
}

class LongPressDetectorState extends State<LongPressDetector> {
  late Timer _timer;
  bool longPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { //Detect when you click the element
        _timer = Timer(
          widget.duration,
          () {
            longPressed = true;
            widget.onLongPressDown();
          },
        );
        print('tapping');
      },
      onTapUp: (_) { // Detect and cancel when you lift the click
        if(longPressed) {
          longPressed = false;
          widget.onLongPressUp();
        }
        _timer.cancel();
        print('cancel');
      },
      child: widget.child
    );
  }
}