import 'package:actpod_web/features/explore_page/components/mobile/podcoin_card.dart';
import 'package:actpod_web/features/explore_page/components/mobile/purchased_card.dart';
import 'package:actpod_web/features/explore_page/components/mobile/story_card.dart';
import 'package:actpod_web/features/explore_page/components/shared/package_card.dart';
import 'package:actpod_web/features/explore_page/components/shared/recommendation_switch.dart';
import 'package:actpod_web/features/explore_page/controllers/story_controller.dart';
import 'package:actpod_web/features/explore_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreMobileScreen extends ConsumerStatefulWidget {
  final StoryController storyController;
  const ExploreMobileScreen({super.key, required this.storyController});

  @override
  ConsumerState<ExploreMobileScreen> createState() =>
      _ExploreMobileScreenState();
}

class _ExploreMobileScreenState extends ConsumerState<ExploreMobileScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final stories = ref.watch(storiesProvider);
    final packages = ref.watch(packagesProvider);
    final purchasedEpisodes = ref.watch(purchasedStoriesProvider);
    final recommendationMode = ref.watch(exploreRecommendationModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        toolbarHeight: 46,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Image.asset(
              "assets/images/actpod_logo_web.png",
              height: 24,
              fit: BoxFit.fitHeight,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // const SearchBox(),
          // const SizedBox(height: 8),
          PodCoinBalanceCard(
            storyController: widget.storyController,
          ),
          const SizedBox(height: 4),
          _SegmentTabs(
            selectedIndex: selectedTab,
            onChanged: (index) {
              setState(() {
                selectedTab = index;
              });
            },
          ),
          const SizedBox(height: 8),
          if (selectedTab == 0) ...[
            RecommendationSwitch(
              selectedMode: recommendationMode,
              onChanged: (mode) {
                ref.watch(exploreRecommendationModeProvider.notifier).state =
                    mode;
              },
            ),
            const SizedBox(height: 8),
            if (recommendationMode == ExploreRecommendationMode.episode) ...[
              if (stories == null)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                ...stories.map(
                  (story) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: MobileStoryCard(story: story),
                  ),
                ),
            ] else ...[
              if (stories == null)
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              if (packages != null)
                ...packages.map(
                  (package) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PackageCard(
                      package: package,
                      compact: true,
                    ),
                  ),
                ),
            ],
          ] else ...[
            if (purchasedEpisodes == null)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              ...purchasedEpisodes.map(
                (episode) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: MobilePurchasedCard(story: episode),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SegmentTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE6E6E6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentTabItem(
              text: "推薦內容",
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
              fontSize: 18,
            ),
          ),
          Expanded(
            child: _SegmentTabItem(
              text: "已購買的付費Podcast",
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTabItem extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final double fontSize;

  const _SegmentTabItem({
    required this.text,
    required this.selected,
    required this.onTap,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: selected ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
          if (selected)
            Container(
              height: 3,
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFFBC1F),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
        ],
      ),
    );
  }
}
