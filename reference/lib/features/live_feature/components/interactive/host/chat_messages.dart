import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/dto/user_info_dto.dart';
import 'package:quick_share_app/features/live_feature/components/create_background_music_dialog.dart';
import 'package:quick_share_app/features/live_feature/controllers/message_controller.dart';
import 'package:quick_share_app/services/user_service.dart';
import 'package:quick_share_app/utils/string_utils.dart';

import '../../../../../design_system/components/podcoin.dart';
import '../../../../../dto/live_room_sticker_dto.dart';
import '../../../../../services/toast_service.dart';
import '../../../controllers/room_controller.dart';
import '../../../dto/background_option_dto.dart';
import '../../../providers.dart';
import '../../background_music_bottom_sheet.dart';
import '../../create_bulletin_dialog.dart';

class ChatMessagesView extends ConsumerStatefulWidget {
  const ChatMessagesView(
      {super.key,
      required this.userId,
      required this.messageController,
      required this.focusNode,
      required this.roomController});

  final FocusNode focusNode;
  final String userId;
  final MessageController messageController;
  final RoomController roomController;

  @override
  ConsumerState<ChatMessagesView> createState() => _ChatMessagesViewState();
}

/// 聊天室畫面（訊息列表 + 自動滑到底）
class _ChatMessagesViewState extends ConsumerState<ChatMessagesView> {
  late final ScrollController _scrollController;
  late final ValueNotifier<bool> _isNearBottom;
  late final ValueNotifier<int> _lastCount;
  late final StreamSubscription<void> _thumbSub;
  final List<_ThumbParticleData> _thumbs = [];
  int _thumbIdSeed = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _isNearBottom = ValueNotifier<bool>(true);
    _lastCount = ValueNotifier<int>(0);

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      const threshold = 120.0;
      final max = _scrollController.position.maxScrollExtent;
      final cur = _scrollController.position.pixels;
      final nearBottom = (max - cur) <= threshold;

      if (_isNearBottom.value != nearBottom) {
        setState(() {
          _isNearBottom.value = nearBottom;
        });
      }
    });

    _thumbSub = widget.messageController.thumbReactionStream.stream.listen((_) {
      _spawnThumb();
    });
  }

  @override
  void dispose() {
    _thumbSub.cancel();
    _scrollController.dispose();
    _isNearBottom.dispose();
    _lastCount.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  void _spawnThumb() {
    if (!mounted) return;

    setState(() {
      _thumbs.add(
        _ThumbParticleData(
          id: _thumbIdSeed++,
          // Start near input bar (bottom-right area)
          startRight: 18 + (_thumbIdSeed % 3) * 14.0,
          // Add slight random-like horizontal drift without importing Random
          driftX: ((_thumbIdSeed % 5) - 2) * 10.0,
          size: 22 + (_thumbIdSeed % 4) * 2.0,
        ),
      );
    });
  }

  void _removeThumb(int id) {
    if (!mounted) return;
    setState(() {
      _thumbs.removeWhere((e) => e.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    // new message handling (optional, but useful)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prevCount = _lastCount.value;
      final newCount = messages.length;
      if (newCount != prevCount) {
        _lastCount.value = newCount;

        // Recompute near-bottom after layout changed (important)
        if (_scrollController.hasClients) {
          const threshold = 120.0;
          final max = _scrollController.position.maxScrollExtent;
          final cur = _scrollController.position.pixels;
          _isNearBottom.value = (max - cur) <= threshold;
        }

        if (_isNearBottom.value) {
          _scrollToBottom(animated: true);
        }
      }
    });

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    if (m.type == "handUp") {
                      return _HandUp(
                          userId: m.userId,
                          avatarUrl: m.avatarUrl,
                          nickname: m.nickname);
                    } else {
                      return _ChatBubble(
                        text: m.content,
                        isHost: m.userId == ref.read(roomInfoProvider)?.hostId,
                        userId: m.userId,
                        avatarUrl: m.avatarUrl,
                        nickname: m.nickname,
                        stickerUrl: m.stickerUrl,
                        donateAmount: m.donateAmount,
                      );
                    }
                  },
                ),

                Positioned(
                  right: 16,
                  bottom: 8,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isNearBottom,
                    builder: (context, nearBottom, _) {
                      if (nearBottom) return const SizedBox.shrink();
                      return FloatingActionButton.small(
                        onPressed: () => _scrollToBottom(animated: true),
                        backgroundColor: DesignColor.actpodPrimary400,
                        child: const Icon(
                          Icons.arrow_downward,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),

                Visibility(
                    visible: _isNearBottom.value,
                    child: Positioned(
                        right: 16,
                        bottom: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: DesignColor.actpodPrimary50,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              widget.messageController.sendThumb();
                            },
                            icon: const Icon(Icons.thumb_up_rounded),
                            color: DesignColor.actpodPrimary500,
                            iconSize: 22,
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              side: WidgetStateProperty.all(BorderSide.none),
                              shape:
                                  WidgetStateProperty.all(const CircleBorder()),
                              elevation: WidgetStateProperty.all(0),
                              shadowColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              surfaceTintColor:
                                  WidgetStateProperty.all(Colors.transparent),
                            ),
                          ),
                        ))),

                ..._thumbs.map(
                  (t) => _FloatingThumb(
                    key: ValueKey(t.id),
                    data: t,
                    onDone: () => _removeThumb(t.id),
                  ),
                ),

                if (ref.watch(selectedStickerProvider) != null &&
                    !ref.watch(showFunctionOptionProvider))
                  Positioned(
                    left: 16,
                    bottom: -4,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _SelectedStickerPreview(
                        sticker: ref.watch(selectedStickerProvider)!,
                        onRemove: () {
                          ref.watch(selectedStickerProvider.notifier).state =
                              null;
                        },
                      ),
                    ),
                  ),

                // faded
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _ChatInputBar(
            onSend: (text, stickerUrl) => widget.messageController
                .sendChat(text, stickerUrl: stickerUrl, donateAmount: 0),
            focusNode: widget.focusNode,
            showFunctionOption: ref.watch(showFunctionOptionProvider),
            isPlayingPodcast: ref.watch(podcastPlayerStatusProvider) ==
                PodcastPlayerStatus.playing,
            onTapFunctionButton: () {
              if (ref.watch(showFunctionOptionProvider)) {
                ref.watch(showFunctionOptionProvider.notifier).state = false;
              } else {
                ref.watch(showFunctionOptionProvider.notifier).state = true;
              }
            },
            onTapCreateBulletin: () async {
              bool? created = await CreateBulletinDialog().show(
                context,
                onSubmit: ({
                  required String title,
                  required String content,
                  required List<String> imagePaths,
                }) async {
                  await widget.roomController.createBulletin(
                      widget.messageController.roomId,
                      title,
                      content,
                      imagePaths.map((path) => File(path)).toList());
                },
              );
              if (created != null && created) {
                widget.messageController.sendCreatedBulletin();
              }
            },
            onTapCreateVote: () {},
            onTapSettingBackgroundMusic: () async {
              BackgroundOptionDto? option = await BackgroundMusicBottomSheet()
                  .showOptionBottomSheet(
                      context: context,
                      options: ref.read(backgroundMusicsProvider));
              if (option == null) {
                return;
              }

              if (option.newMusic) {
                if (context.mounted) {
                  await CreateBackgroundMusicDialog()
                      .show(context, widget.roomController);
                }
              } else if (option.stopMusic) {
                widget.messageController.sendStopBackgroundMusic();
              } else {
                widget.messageController.sendPlayBackgroundMusic(
                    option.musicDto!.backgroundMusicId);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ThumbParticleData {
  final int id;
  final double startRight;
  final double driftX;
  final double size;

  _ThumbParticleData({
    required this.id,
    required this.startRight,
    required this.driftX,
    required this.size,
  });
}

class _FloatingThumb extends StatefulWidget {
  final _ThumbParticleData data;
  final VoidCallback onDone;

  const _FloatingThumb({
    super.key,
    required this.data,
    required this.onDone,
  });

  @override
  State<_FloatingThumb> createState() => _FloatingThumbState();
}

class _FloatingThumbState extends State<_FloatingThumb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDone();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double startBottom = 0;
    const double riseDistance = 280;

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        final t = _progress.value;

        final bottom = startBottom + (riseDistance * t);
        final right = widget.data.startRight + (widget.data.driftX * t);

        double opacity;
        if (t < 0.7) {
          opacity = 1.0;
        } else {
          opacity = (1.0 - ((t - 0.7) / 0.3)).clamp(0.0, 1.0);
        }

        final scale = (t < 0.15)
            ? (0.8 + t * 1.8)
            : (1.05 - ((t - 0.15) * 0.1)).clamp(0.85, 1.1);

        return Positioned(
          right: right,
          bottom: bottom,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Icon(
                  Icons.thumb_up,
                  size: widget.data.size,
                  color: DesignColor.actpodPrimary400,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HandUp extends StatelessWidget {
  final String userId;
  final String avatarUrl;
  final String nickname;

  const _HandUp({
    required this.userId,
    required this.avatarUrl,
    required this.nickname,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
          color: DesignColor.actpodPrimary400,
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LiveChatAvatar(
            userId: userId,
            avatarUrl: avatarUrl,
            nickname: nickname,
            isHost: false,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            "${StringUtils.shorten(nickname, 8)}  舉手了",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String userId;
  final String avatarUrl;
  final String nickname;
  final String text;
  final bool isHost;
  final String? stickerUrl;
  final int? donateAmount;

  const _ChatBubble({
    required this.text,
    required this.isHost,
    required this.userId,
    required this.avatarUrl,
    required this.nickname,
    required this.stickerUrl,
    required this.donateAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LiveChatAvatar(
            userId: userId,
            avatarUrl: avatarUrl,
            nickname: nickname,
            isHost: isHost,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 80),
                  child: Text(
                    StringUtils.shorten(nickname, 8),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      backgroundColor:
                          isHost ? DesignColor.actpodPrimary400 : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (text.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: SelectableText(
                              text,
                              textAlign: TextAlign.start,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        if (stickerUrl != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 64,
                                child: Image.network(
                                  stickerUrl!,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              if (donateAmount != null && donateAmount! > 0)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PodCoin(size: 16),
                                      const SizedBox(width: 4),
                                      Text(donateAmount.toString()),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveChatAvatar extends StatelessWidget {
  final String userId;
  final String avatarUrl;
  final String nickname;
  final bool isHost;

  const _LiveChatAvatar({
    required this.userId,
    required this.avatarUrl,
    required this.nickname,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return _LiveChatUserInfoSheet(
              userId: userId,
              avatarUrl: avatarUrl,
              nickname: nickname,
              isHost: isHost,
            );
          },
        );
      },
      child: _LiveChatAvatarImage(avatarUrl: avatarUrl, size: 24.w),
    );
  }
}

class _LiveChatUserInfoSheet extends StatelessWidget {
  final String userId;
  final String avatarUrl;
  final String nickname;
  final bool isHost;

  const _LiveChatUserInfoSheet({
    required this.userId,
    required this.avatarUrl,
    required this.nickname,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<UserInfoDto?>(
        future: UserService.getOtherUserInfo(userId),
        builder: (context, snapshot) {
          final userInfo = snapshot.data;
          final displayAvatarUrl = userInfo?.avatarUrl ?? avatarUrl;
          final displayName = userInfo?.nickname ?? nickname;
          final description = userInfo?.selfDescription ?? "";

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DesignColor.neutral200,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 20),
                _LiveChatAvatarImage(avatarUrl: displayAvatarUrl, size: 72),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isHost) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: DesignColor.actpodPrimary400,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          "Podcaster",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (snapshot.connectionState == ConnectionState.waiting) ...[
                  const SizedBox(height: 16),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ] else if (description.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: DesignColor.neutral500,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LiveChatAvatarImage extends StatelessWidget {
  final String? avatarUrl;
  final double size;

  const _LiveChatAvatarImage({
    required this.avatarUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return ClipOval(
        child: Image.asset(
          "assets/images/avatar.png",
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ChatInputBar extends ConsumerStatefulWidget {
  final void Function(String text, String? sticker) onSend;
  final FocusNode focusNode;
  final bool showFunctionOption;
  final bool isPlayingPodcast;
  final VoidCallback? onTapFunctionButton;
  final VoidCallback? onTapCreateBulletin;
  final VoidCallback? onTapCreateVote;
  final VoidCallback? onTapSettingBackgroundMusic;

  const _ChatInputBar({
    required this.onSend,
    required this.focusNode,
    required this.showFunctionOption,
    required this.isPlayingPodcast,
    required this.onTapFunctionButton,
    required this.onTapCreateBulletin,
    required this.onTapCreateVote,
    required this.onTapSettingBackgroundMusic,
  });

  @override
  ConsumerState<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<_ChatInputBar> {
  final _controller = TextEditingController();

  _ChatInputBarState();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty && ref.read(selectedStickerProvider) == null) {
      ToastService.showNoticeToast("請說點什麼");
      return;
    }
    widget.onSend(text, ref.read(selectedStickerProvider));
    _controller.clear();
    ref.watch(selectedStickerProvider.notifier).state = null;
    widget.focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Row(
          children: [
            IconButton(
              onPressed: widget.onTapFunctionButton,
              style: IconButton.styleFrom(
                minimumSize: const Size(28, 28),
                maximumSize: const Size(28, 28),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fixedSize: const Size(28, 28),
                shape: const CircleBorder(),
                side: const BorderSide(
                  color: Color(0xFFBDBDBD),
                  width: 2,
                ),
                backgroundColor: Colors.white,
              ),
              icon: Icon(
                widget.showFunctionOption
                    ? Icons.close_rounded
                    : Icons.add_rounded,
                size: 18,
                color: Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Visibility(
                visible: widget.showFunctionOption,
                child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Material(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: DesignColor.neutral200),
                          ),
                          child: InkWell(
                            onTap: widget.onTapCreateBulletin,
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Text(
                                "創建公布欄",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Visibility(
                            visible: !widget.isPlayingPodcast,
                            child: Material(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: DesignColor.neutral200),
                              ),
                              child: InkWell(
                                onTap: widget.onTapSettingBackgroundMusic,
                                borderRadius: BorderRadius.circular(12),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text(
                                    "背景音樂",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ))),
            Visibility(
                visible: !widget.showFunctionOption,
                child: Expanded(
                  child: TextField(
                    cursorColor: DesignColor.actpodPrimary500,
                    focusNode: widget.focusNode,
                    controller: _controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "發表留言…",
                      isDense: true,
                      filled: true,
                      fillColor: const Color(0xFFF2F2F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        iconSize: 24,
                        onPressed: () async {
                          widget.focusNode.unfocus();
                          await _showStickerBottomSheet(
                              context, ref.watch(stickersProvider));
                        },
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                )),
            Visibility(
                visible: !widget.showFunctionOption,
                child: IconButton(
                  onPressed: _send,
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.send,
                    color: DesignColor.actpodPrimary400,
                    size: 28,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _showStickerBottomSheet(
      BuildContext context, List<LiveRoomStickerDto> stickers) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '選擇貼圖',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: stickers.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final sticker = stickers[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          ref.watch(selectedStickerProvider.notifier).state =
                              sticker.url;
                          Navigator.pop(context);
                        },
                        child: Container(
                            width: 72,
                            height: 72,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SizedBox(
                              width: 64,
                              child: Image.network(
                                sticker.url,
                                fit: BoxFit.fitWidth,
                              ),
                            )),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SelectedStickerPreview extends StatelessWidget {
  final String sticker;
  final VoidCallback onRemove;

  const _SelectedStickerPreview({
    required this.sticker,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
              ),
            ),
            child: SizedBox(
              width: 64,
              child: Image.network(
                sticker,
                fit: BoxFit.fitWidth,
              ),
            )),
        Positioned(
          right: -6,
          top: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
