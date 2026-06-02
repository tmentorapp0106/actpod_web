import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/shorts_feature/components/shorts_video.dart';
import 'package:quick_share_app/features/shorts_feature/controllers/shorts_controller.dart';
import 'package:quick_share_app/features/shorts_feature/providers.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/services/audio_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ShortsScreen extends ConsumerStatefulWidget {
  const ShortsScreen({super.key});

  @override
  ConsumerState<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends ConsumerState<ShortsScreen> {
  late final PageController _pageController;
  ShortsController? shortsController;

  final Map<int, YoutubePlayerController> _controllers = {};

  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    shortsController = ShortsController(ref);

    // Autoplay first page after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      shortsController!.getShorts();
    });
  }

  void _onPageChanged(int newIndex) {
    final old = _index;
    _controllers[old]?.pause();

    setState(() => _index = newIndex);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: ref.watch(shortsProvider) == null? Center(
        child: CircularProgressIndicator(
          color: DesignColor.actpodPrimary400,
        )
      ) : PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: ref.watch(shortsProvider)!.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, i) {
          final c = _controllers.putIfAbsent(i, () {
            return YoutubePlayerController(
              initialVideoId: ref.watch(shortsProvider)![i].videoId,
              flags: const YoutubePlayerFlags(
                autoPlay: true,
                mute: true,             // important for iOS autoplay
                hideControls: true,
                loop: true,
                disableDragSeek: true,
                controlsVisibleAtStart: false,
                hideThumbnail: true
              ),
            );
          });
          
          return Stack(
            children: [
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(0, -8), // move up 8px (negative = up)
                  child: ShortsVideo(
                    short: ref.watch(shortsProvider)![i],
                    controller: c,
                    pageIndex: i,
                    currentIndex: _index,
                  ),
                ),
              ),
            ],
          );
        },
      )
    );
  }
}