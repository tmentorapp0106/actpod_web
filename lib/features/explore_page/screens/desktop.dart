import 'package:actpod_web/features/explore_page/components/desktop/podcoin_card.dart';
import 'package:actpod_web/features/explore_page/components/desktop/purchased_episodes.dart';
import 'package:actpod_web/features/explore_page/components/desktop/story_card.dart';
import 'package:actpod_web/features/explore_page/components/desktop/top_nav_bar.dart';
import 'package:actpod_web/features/explore_page/components/shared/package_card.dart';
import 'package:actpod_web/features/explore_page/components/shared/recommendation_switch.dart';
import 'package:actpod_web/features/explore_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreDesktopScreen extends ConsumerWidget {
  const ExploreDesktopScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = ref.watch(storiesProvider);
    final packages = ref.watch(packagesProvider);
    final purchasedEpisodes = ref.watch(storiesProvider);
    final recommendationMode = ref.watch(exploreRecommendationModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          Column(
            children: [
              const TopNavBar(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(28, 12, 16, 50),
                        children: [
                          // const CategoryFilterRow(),
                          // const SizedBox(height: 18),
                          const _SectionTitle(title: "推薦內容"),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 390,
                            child: RecommendationSwitch(
                              selectedMode: recommendationMode,
                              onChanged: (mode) {
                                ref
                                    .watch(
                                      exploreRecommendationModeProvider
                                          .notifier,
                                    )
                                    .state = mode;
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (recommendationMode ==
                              ExploreRecommendationMode.episode) ...[
                            if (stories == null)
                              const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            if (stories != null)
                              ...stories.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 18),
                                  child: StoryCardDesktop(story: e),
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
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: PackageCard(package: package),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 330,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(0, 24, 28, 110),
                        children: [
                          const PodCoinCard(),
                          const SizedBox(height: 18),
                          PurchasedEpisodesPanel(items: purchasedEpisodes),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SelectableText(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Image.asset(
          "assets/images/poder_1.png",
          height: 40,
        )
      ],
    );
  }
}

class CategoryItem {
  final String title;
  final IconData icon;

  CategoryItem({
    required this.title,
    required this.icon,
  });
}
