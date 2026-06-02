import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class EmptyStory extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Visibility(
        visible: ref.watch(collectionStoryListProvider) != null && ref.watch(collectionStoryListProvider)!.isEmpty,
        child: SizedBox(
          height: 500,
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Image.asset(
                  "assets/images/actpod_wordless.png",
                  height: 300,
                  fit: BoxFit.fitHeight,
                ),
                const SizedBox(height: 8,),
                const Text(
                  "快去收藏頻道！",
                  style: TextStyle(
                    fontSize: 28
                  ),
                ),
              ],
            )
          )
        )
      )
    );
  }
}