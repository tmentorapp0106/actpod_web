import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';

class HoldToRecordButton extends StatefulWidget {
  final Future<void> Function() onStartRecording;
  final Future<void> Function({bool canceled}) onStopRecording;
  final double cancelDistance; // how far user must slide up to cancel

  const HoldToRecordButton({
    super.key,
    required this.onStartRecording,
    required this.onStopRecording,
    this.cancelDistance = 60,
  });

  @override
  State<HoldToRecordButton> createState() => _HoldToRecordButtonState();
}

class _HoldToRecordButtonState extends State<HoldToRecordButton> {
  bool _isRecording = false;
  bool _willCancel = false;

  Offset? _startGlobalPos;

  Future<void> _start() async {
    if (_isRecording) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isRecording = true;
      _willCancel = false;
    });
    await widget.onStartRecording();
  }

  Future<void> _end({required bool canceled}) async {
    if (!_isRecording) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isRecording = false;
      _willCancel = false;
    });
    await widget.onStopRecording(canceled: canceled);
  }

  @override
  Widget build(BuildContext context) {
    // final bg = _isRecording
    //     ? (_willCancel ? Colors.red : Colors.blue.shade600)
    //     : Colors.blue;
    final bg = _isRecording? Colors.red : DesignColor.primary50;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      // Fires when long-press threshold is reached (~500ms)
      onLongPressStart: (details) {
        _startGlobalPos = details.globalPosition;
        _start();
      },


      // Track finger while holding to support “slide up to cancel”
      onLongPressMoveUpdate: (details) {
        if (_startGlobalPos == null) return;
        final dy = details.globalPosition.dy - _startGlobalPos!.dy;
        final willCancel = dy < -widget.cancelDistance; // dragged up enough
        if (willCancel != _willCancel) {
          setState(() => _willCancel = willCancel);
        }
      },

      onLongPressEnd: (_) {
        _end(canceled: _willCancel);
        _startGlobalPos = null;
      },

      onTapCancel: () {
        _end(canceled: true);
        _startGlobalPos = null;
      },

      child: _isRecording? Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          // borderRadius: BorderRadius.circular(28),
          shape: BoxShape.circle,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isRecording ? Icons.fiber_manual_record_rounded : Icons.mic,
              color: Colors.white,
              size: 52.w,
            ),
          ],
        ),
      ) : Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: Ink(
          decoration: BoxDecoration(
            color: DesignColor.primary50,
            shape: BoxShape.circle,
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {},
            splashColor: Colors.white.withOpacity(0.40),
            highlightColor: Colors.white.withOpacity(0.06),

            // Optional extra scale animation for “press”
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Icon(
                Icons.mic,
                color: Colors.white,
                size: 60, // or 60.w if using sizer
              ),
            ),
          ),
        ),
      )
    );
  }
}
