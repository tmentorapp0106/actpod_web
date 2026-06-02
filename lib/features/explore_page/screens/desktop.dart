import 'package:actpod_web/features/explore_page/components/desktop/category_filter_row.dart';
import 'package:actpod_web/features/explore_page/components/desktop/podcoin_card.dart';
import 'package:actpod_web/features/explore_page/components/desktop/purchased_episodes.dart';
import 'package:actpod_web/features/explore_page/components/desktop/story_card.dart';
import 'package:actpod_web/features/explore_page/components/desktop/top_nav_bar.dart';
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
    final purchasedEpisodes = ref.watch(storiesProvider);

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
                          if(stories == null)
                            const Center(child: CircularProgressIndicator(strokeWidth: 2,),) ,
                          if(stories != null)
                            ...stories.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: StoryCardDesktop(story: e),
                              )
                            ),
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
        Text(
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

class _DesktopPlayerBar extends StatelessWidget {
  const _DesktopPlayerBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Row(
            children: [
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(10),
              //   child: Image.network(
              //     mockPurchasedEpisodes.first.coverUrl,
              //     width: 58,
              //     height: 58,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(
                    width: 220,
                    child: Text(
                      "#1 在日本想拍照或錄影？這樣問最自然",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "無壓力學日文 with yuma",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.shuffle, color: Colors.black54),
          const SizedBox(width: 24),
          const Icon(Icons.skip_previous_rounded, size: 30),
          const SizedBox(width: 18),
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFBC1F),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 18),
          const Icon(Icons.skip_next_rounded, size: 30),
          const SizedBox(width: 24),
          const Icon(Icons.repeat, color: Colors.black54),
          const SizedBox(width: 26),
          const Text(
            "08:32 / 18:32",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(width: 26),
          const Icon(Icons.volume_up_outlined, color: Colors.black54),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: 0.58,
                onChanged: (_) {},
                activeColor: const Color(0xFFFFBC1F),
                inactiveColor: const Color(0xFFE0E0E0),
              ),
            ),
          ),
          const SizedBox(width: 22),
          const Icon(Icons.list_alt_rounded, color: Colors.black54),
          const SizedBox(width: 20),
          const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.black54),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFF3C6) : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected ? const Color(0xFF4E3312) : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}