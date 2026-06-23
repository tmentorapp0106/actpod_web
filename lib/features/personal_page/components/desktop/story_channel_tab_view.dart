import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/personal_page/components/desktop/channels_view.dart';
import 'package:actpod_web/features/personal_page/components/desktop/stories_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopStoryChannelTabView extends ConsumerWidget {
  final TabController controller;

  const DesktopStoryChannelTabView(this.controller, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 320,
              child: TabBar(
                indicator: UnderlineTabIndicator(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: DesignColor.primary50,
                    width: 4,
                  ),
                  insets: const EdgeInsets.symmetric(horizontal: 32),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.black,
                controller: controller,
                tabs: const [
                  Tab(
                    child: Text(
                      "故事",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "頻道",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              controller: controller,
              children: const [
                DesktopStoriesView(),
                DesktopChannelsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
