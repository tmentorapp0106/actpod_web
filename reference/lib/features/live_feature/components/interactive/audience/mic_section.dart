import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/features/live_feature/controllers/message_controller.dart';
import 'package:quick_share_app/features/live_feature/providers.dart';
import 'package:quick_share_app/utils/string_utils.dart';
import 'package:livekit_client/livekit_client.dart' as livekit_client;

import '../../../../../components/avatar.dart';
import '../../../../../design_system/color.dart';
import '../../../../../design_system/design.dart';
import '../../../../../dto/live_room_member_dto.dart';
import '../../../../../services/user_service.dart';
import '../../../dto/ws_message_dto.dart';
import '../background_music.dart';
import 'member_count.dart';

class MicSection extends ConsumerWidget {
  final MessageController messageController;
  final StreamController<MicPermissionAction> micPermissionRoomStream;

  MicSection({required this.messageController, required this.micPermissionRoomStream});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomInfo = ref.watch(roomInfoProvider);
    final onMicMembers = ref.watch(onMicMembersProvider);
    String userId = UserService.getUserInfo()!.userId;
    bool selfOnMicStatus = onMicMembers.any((m) => m.userId == userId);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: DesignSystem.shadow,
        color: Colors.white,
      ),
      child: Stack(
        children: [
          // Main content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Host(
                avatarUrl: roomInfo?.hostAvatarUrl ?? "",
                nickname: roomInfo?.hostName ?? "",
              ),
              const SizedBox(height: 2),
              SizedBox(
                width: 340.w,
                child: MicDividerSection(
                  onMicStatus: selfOnMicStatus,
                  messageController: messageController,
                  micOpened: ref.watch(onMicProvider),
                  handsUp: ref.watch(handsUpProvider),
                  micPermissionRoomStream: micPermissionRoomStream,
                  connectionState: ref.watch(livekitConnectionStateProvider),
                ),
              ),
              const SizedBox(height: 4),
              OnMicRow(members: onMicMembers),
            ],
          ),

          // Top-right MemberCount
          Positioned(
            top: 0,
            right: 0,
            child: MemberCount(),
          ),
        ],
      ),
    );
  }
}

class Host extends StatelessWidget {
  final String avatarUrl;
  final String nickname;

  const Host({super.key, required this.avatarUrl, required this.nickname});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Avatar(null, avatarUrl, 48),
        const SizedBox(height: 2,),
        Text(
          StringUtils.shorten(nickname, 10)
        )
      ],
    );
  }
}

class OnMicRow extends StatelessWidget {
  final List<LiveRoomMemberDto> members;

  const OnMicRow({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8.h,
      children: members.map((member) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            avatar(member.avatarUrl, member.isSpeaking),
            const SizedBox(height: 2),
            Text(
              StringUtils.shorten(member.nickname, 5),
              style: TextStyle(
                fontSize: 12
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget avatar(String? avatarUrl, bool isSpeaking) {
    final imageWidget = avatarUrl == null || avatarUrl == ""
        ? Image.asset(
      "assets/images/avatar.png",
      width: 40,
      height: 40,
      fit: BoxFit.cover,
    )
        : Image.network(
      avatarUrl,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
    );

    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSpeaking
            ? Border.all(
          color: DesignColor.actpodPrimary400,
          width: 2,
        )
            : null,
      ),
      child: ClipOval(child: imageWidget),
    );
  }
}

class MicDividerSection extends ConsumerWidget {
  final bool onMicStatus;
  final bool micOpened;
  final bool handsUp;
  final MessageController messageController;
  final StreamController<MicPermissionAction> micPermissionRoomStream;
  final livekit_client.ConnectionState connectionState;

  const MicDividerSection({
    super.key, 
    required this.onMicStatus, 
    required this.micOpened, 
    required this.handsUp, 
    required this.messageController, 
    required this.micPermissionRoomStream,
    required this.connectionState
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: Colors.white,
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: const [
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: Color(0xFFE0E0E0),
                  ),
                ),
              ],
            ),

            // mic exactly centered
            Visibility(
              visible: onMicStatus,
              child: GestureDetector(
                onTap: connectionState == livekit_client.ConnectionState.connected
                    ? () {
                  if (micOpened) {
                    micPermissionRoomStream.add(MicPermissionAction.revoke);
                  } else {
                    micPermissionRoomStream.add(MicPermissionAction.granted);
                  }
                }
                    : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: micOpened
                        ? DesignColor.actpodPrimary400 : const Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                    border: const Border.fromBorderSide(
                      BorderSide(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Center(
                    child: connectionState == livekit_client.ConnectionState.connected
                        ? Icon(
                      micOpened ? Icons.mic : Icons.mic_off_rounded,
                      color: micOpened ? Colors.white : Colors.grey,
                      size: 24,
                    )
                        : const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              )
            ),

            Visibility(
              visible: !onMicStatus,
              child: GestureDetector(
                onTap: () {
                  if(handsUp) {
                    messageController.sendHandDown();
                  } else {
                    messageController.sendHandUp();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: handsUp? DesignColor.neutral300 : DesignColor.actpodPrimary400,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.fromBorderSide(
                      BorderSide(
                        color: Colors.white,
                        width: 4, // border thickness
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        handsUp? "取消請求" : '請求上麥',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              )
            ),

            // logout pinned to right
            Visibility(
              visible: onMicStatus,
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    String userId = UserService.getUserInfo()!.userId;
                    messageController.sendRevokeMic(userId);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F0F0),
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(
                          color: Colors.white,
                          width: 4, // border thickness
                        ),
                      ),
                    ),
                    child: connectionState == livekit_client.ConnectionState.connected
                        ? const Icon(
                      Icons.logout_rounded,
                      color: Colors.grey,
                      size: 24,
                    ) : const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              )
            ),
          ],
        ),
      ),
    );
  }
}