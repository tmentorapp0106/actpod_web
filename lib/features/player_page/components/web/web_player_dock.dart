part of 'player_web_screen.dart';

class _WebPlayerDock extends ConsumerWidget {
  final PlayerController playerController;

  const _WebPlayerDock({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioLength = ref.watch(audioLengthProvider);
    final seekPosition = ref.watch(audioPositionProvider);
    final playerState = ref.watch(playerStatusProvider);
    final likeCount = ref.watch(storyStateProvider)?.likeCount.toString() ?? "";

    final totalMs = audioLength.inMilliseconds;
    final positionMs = seekPosition.inMilliseconds.clamp(0, totalMs);
    final sliderMax = totalMs <= 0 ? 1.0 : totalMs.toDouble();
    final sliderValue = totalMs <= 0 ? 0.0 : positionMs.toDouble();

    return Center(
      child: Container(
        width: 620,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: DesignShadow.shadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: DesignColor.primary50,
                inactiveTrackColor: const Color(0xFFD6D6D6),
                thumbColor: DesignColor.primary50,
                overlayColor: DesignColor.primary50.withValues(alpha: 0.16),
              ),
              child: Slider(
                min: 0,
                max: sliderMax,
                value: sliderValue,
                onChanged: totalMs <= 0
                    ? null
                    : (value) {
                        playerController.seekPosition(
                          Duration(milliseconds: value.round()),
                        );
                      },
              ),
            ),
            Row(
              children: [
                Text(
                  TimeUtils.formatDuration(seekPosition, "HH:mm:ss"),
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),
                Text(
                  TimeUtils.formatDuration(audioLength, "HH:mm:ss"),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WebSpeedDropdown(playerController: playerController),
                _WebIconButton(
                  icon: Image.asset(
                    "assets/icons/backward_15.png",
                    width: 30,
                    height: 30,
                  ),
                  onTap: () {
                    playerController.backward(const Duration(seconds: 15));
                  },
                ),
                _WebPlayControl(
                  playerController: playerController,
                  playerState: playerState,
                ),
                _WebIconButton(
                  icon: Image.asset(
                    "assets/icons/forward_15.png",
                    width: 30,
                    height: 30,
                  ),
                  onTap: () {
                    playerController.forward(const Duration(seconds: 15));
                  },
                ),
                SizedBox(
                  width: 72,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      final storyId = ref.read(storyStateProvider)?.storyId;
                      if (storyId != null) {
                        _openStoryDeepLink(context, storyId);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: DesignColor.primary50,
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            likeCount,
                            style: const TextStyle(
                              color: DesignColor.neutral70,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WebSpeedDropdown extends ConsumerWidget {
  final PlayerController playerController;

  const _WebSpeedDropdown({required this.playerController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 72,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: ref.watch(playerSpeedTextProvider),
          isDense: true,
          alignment: Alignment.center,
          items: const ["1.0X", "0.5X", "1.5X"]
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  alignment: Alignment.center,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            ref.read(playerSpeedTextProvider.notifier).state = value;
            if (value == "1.5X") {
              playerController.setSpeed(1.5);
            } else if (value == "0.5X") {
              playerController.setSpeed(0.5);
            } else {
              playerController.setSpeed(1.0);
            }
          },
        ),
      ),
    );
  }
}

class _WebIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const _WebIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: SizedBox(
        width: 52,
        height: 44,
        child: Center(child: icon),
      ),
    );
  }
}

class _WebPlayControl extends ConsumerWidget {
  final PlayerController playerController;
  final PlayerStatus playerState;

  const _WebPlayControl({
    required this.playerController,
    required this.playerState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (playerState == PlayerStatus.unpaid) {
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => createStoryCreditCardPayment(context, ref),
        child: Image.asset(
          "assets/images/podcoins.png",
          width: 46,
          height: 46,
          fit: BoxFit.fitWidth,
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        if (playerState == PlayerStatus.preparing) {
          return;
        }
        if (playerState == PlayerStatus.playing) {
          playerController.pause();
        } else {
          playerController.play();
        }
      },
      child: SizedBox(
        width: 56,
        height: 56,
        child: Center(
          child: playerState == PlayerStatus.preparing
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: DesignColor.primary50,
                    strokeWidth: 2.4,
                  ),
                )
              : Icon(
                  playerState == PlayerStatus.playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 52,
                  color: DesignColor.primary50,
                ),
        ),
      ),
    );
  }
}
