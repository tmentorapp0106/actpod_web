import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_share_app/config/color.dart';
import 'package:quick_share_app/design_system/color.dart';
import 'package:quick_share_app/features/live_feature/components/interactive/background_music.dart';
import 'package:quick_share_app/features/live_feature/components/interactive/host/member_count.dart';
import 'package:quick_share_app/features/live_feature/controllers/message_controller.dart';
import 'package:quick_share_app/features/live_feature/providers.dart';
import 'package:quick_share_app/utils/string_utils.dart';
import 'package:livekit_client/livekit_client.dart' as livekit_client;

import '../../../../../components/avatar.dart';
import '../../../../../design_system/design.dart';
import '../../../../../dto/live_room_member_dto.dart';
import '../../../../../dto/user_info_dto.dart';
import '../../../../../services/user_service.dart';
import '../../../dto/mic_action_dto.dart';
import '../../../dto/ws_message_dto.dart';

class MicSection extends ConsumerWidget {
  final MessageController messageController;
  final StreamController<MicPermissionAction> micPermissionRoomStream;
  final StreamController<MemberActionDto> memberActionStream;

  MicSection({required this.messageController, required this.micPermissionRoomStream, required this.memberActionStream});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = UserService.getUserInfo();
    final onMicMembers = ref.watch(onMicMembersProvider);
    final onMic = ref.watch(onMicProvider);

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
              Host(userInfo: userInfo!),
              SizedBox(
                width: 340.w,
                child: MicDividerSection(
                  messageController: messageController,
                  onMic: onMic,
                  micPermissionRoomStream: micPermissionRoomStream,
                  connectionState: ref.watch(livekitConnectionStateProvider),
                ),
              ),
              const SizedBox(height: 2),
              OnMicRow(
                members: onMicMembers,
                memberActionStream: memberActionStream,
              ),
            ],
          ),

          // Top-right MemberCount
          Positioned(
            top: 0,
            right: 0,
            child: MemberCount(
              memberActionStream: memberActionStream,
            ),
          ),
        ],
      ),
    );
  }
}

class Host extends StatelessWidget {
  final UserInfoDto userInfo;

  const Host({super.key, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Avatar(null, userInfo.avatarUrl, 48),
        const SizedBox(height: 2,),
        Text(
          StringUtils.shorten(userInfo.nickname, 10)
        )
      ],
    );
  }
}

class OnMicRow extends StatelessWidget {
  final List<LiveRoomMemberDto> members;
  final StreamController<MemberActionDto> memberActionStream;

  const OnMicRow({super.key, required this.members, required this.memberActionStream});

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
        return GestureDetector(
          onTap: () {
            memberActionStream.add((MemberActionDto(memberAction: MemberAction.attemptToRevokeMic, memberInfo: member)));
          },
          child: Column(
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
          )
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
  final MessageController messageController;
  final bool onMic;
  final StreamController<MicPermissionAction> micPermissionRoomStream;
  final livekit_client.ConnectionState connectionState;

  const MicDividerSection({
    super.key,
    required this.messageController,
    required this.onMic,
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
            GestureDetector(
              onTap: connectionState == livekit_client.ConnectionState.connected
                  ? () {
                if (onMic) {
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
                  color: onMic ? DesignColor.actpodPrimary400 : const Color(0xFFF0F0F0),
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
                    onMic ?  Icons.mic_rounded : Icons.mic_off_rounded,
                    color: onMic?  Colors.white : Colors.grey,
                    size: 24,
                  )
                      : const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // logout pinned to right
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  if(connectionState != livekit_client.ConnectionState.connected) {
                    return;
                  }
                  messageController.sendStopLiveKit();
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
                  child: Center(
                    child: connectionState == livekit_client.ConnectionState.connected
                        ? const Icon(
                      Icons.logout_rounded,
                      color: Colors.grey,
                      size: 24,
                    )
                        : const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}