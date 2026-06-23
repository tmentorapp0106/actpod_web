import 'package:actpod_web/const.dart';
import 'package:actpod_web/dto/channel_dto.dart';
import 'package:actpod_web/features/personal_page/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class DesktopChannelsView extends ConsumerWidget {
  const DesktopChannelsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelList = ref.watch(channelListProvider);

    if (channelList == null || channelList.isEmpty) {
      return const _DesktopEmptyView(
        assetName: "assets/images/empty_collections.svg",
        label: "尚無頻道",
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 32),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 240,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
      ),
      itemCount: channelList.length,
      itemBuilder: (context, index) {
        return _DesktopChannelCard(channel: channelList[index]);
      },
    );
  }
}

class _DesktopChannelCard extends StatelessWidget {
  final ChannelDto channel;

  const _DesktopChannelCard({
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ChannelImage(channel: channel),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.62),
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.48),
                  ],
                  stops: const [0.0, 0.52, 1.0],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Text(
                channel.channelName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelImage extends StatelessWidget {
  final ChannelDto channel;

  const _ChannelImage({
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    if (channel.channelImageUrl.isEmpty) {
      return Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Text(
          channel.channelName.isEmpty ? "" : channel.channelName[0],
          style: const TextStyle(
            fontSize: 72,
            color: Colors.black87,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Image.network(
      imgProxy + channel.channelImageUrl,
      fit: BoxFit.cover,
    );
  }
}

class _DesktopEmptyView extends StatelessWidget {
  final String assetName;
  final String label;

  const _DesktopEmptyView({
    required this.assetName,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            assetName,
            color: Colors.grey,
            width: 120,
            height: 120,
            fit: BoxFit.fitWidth,
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
