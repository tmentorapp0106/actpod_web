import 'package:actpod_web/features/player_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileInstantComments extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(playContentProvider) == PlayContent.story,
      child: Positioned.fill(
        child: IgnorePointer(
          ignoring: false, // comments are decorative; remove if tappable
          child: ClipRect(
            child: Stack(children: ref.watch(instantCommentWidgets)),
          ),
        ),
      )
    );
  }
}