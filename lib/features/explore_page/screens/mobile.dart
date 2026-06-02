import 'package:actpod_web/const.dart';
import 'package:actpod_web/features/explore_page/components/mobile/podcoin_card.dart';
import 'package:actpod_web/features/explore_page/components/mobile/search_box.dart';
import 'package:actpod_web/features/explore_page/components/mobile/story_card.dart';
import 'package:actpod_web/features/explore_page/dto/story_info_dto.dart';
import 'package:actpod_web/features/explore_page/providers.dart';
import 'package:actpod_web/utils/time_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreMobileScreen extends ConsumerStatefulWidget {
  const ExploreMobileScreen({
    super.key,
  });

  @override
  ConsumerState<ExploreMobileScreen> createState() =>
      _ExploreMobileScreenState();
}

class _ExploreMobileScreenState extends ConsumerState<ExploreMobileScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final stories = ref.watch(storiesProvider);
    final purchasedEpisodes = ref.watch(storiesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Image.asset(
              "assets/images/actpod_logo_web.png",
              height: 32,
              fit: BoxFit.fitHeight,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const SearchBox(),

          const SizedBox(height: 8),

          const PodCoinBalanceCard(),

          const SizedBox(height: 4),

          _SegmentTabs(
            selectedIndex: selectedTab,
            onChanged: (index) {
              setState(() {
                selectedTab = index;
              });
            },
          ),

          const SizedBox(height: 18),

          if (selectedTab == 0) ...[
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
                  child: MobileStoryCard(story: episode),
                ),
              ),
          ],
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Colors.black87,
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
            ),
          ),
          Expanded(
            child: _SegmentTabItem(
              text: "已購買的付費Podcast`",
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
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

  const _SegmentTabItem({
    required this.text,
    required this.selected,
    required this.onTap,
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
                fontSize: 18,
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



class _PurchasedEpisodeCard extends StatelessWidget {
  final StoryInfoDto item;

  const _PurchasedEpisodeCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imgProxy + item.storyImageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.storyName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.channelName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const Spacer(),
                Text(
                  TimeUtils.formatDuration(Duration(milliseconds: item.totalLength), "HH:mm:ss"),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          _PlayCircleButton(
            onTap: () {},
            size: 40,
            iconSize: 24,
          ),
        ],
      ),
    );
  }
}

class _PlayCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _PlayCircleButton({
    required this.onTap,
    this.size = 46,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFBC1F),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}