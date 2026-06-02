import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/features/channel_page_feature/provider.dart';
import 'package:quick_share_app/features/podcast_store_feature/screens/podcast_store.dart';

import '../../../design_system/color.dart';

class PodcastStoreButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: ref.watch(podcastStoreProvider) != null,
      child: Expanded(
        child: OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PodcastStoreScreen(podcastStore: ref.read(podcastStoreProvider),)
            ));
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: DesignColor.actpodPrimary500,
            side: const BorderSide(color: DesignColor.actpodPrimary500, width: 1.5),
            shape: const StadiumBorder(), // ✅ 膠囊形
            // padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Podcast store",
                style: TextStyle(
                  color: DesignColor.actpodPrimary500,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5, // 讓字距像圖那樣鬆一點
                ),
              ),
            ],
          ),
        )
      )
    );
  }
}