import 'dart:async';

import 'package:actpod_web/features/live_page/dto/member.dart';
import 'package:actpod_web/features/live_page/dto/member_action.dart';
import 'package:actpod_web/features/live_page/providers/room.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MembersBottomSheet {
  void show(
      BuildContext context, {
        required bool isInteractiveHost,
        required bool livekitConnected,
        StreamController<MemberActionDto>? memberActionStream
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _AudienceBottomSheet(
          livekitConnected: livekitConnected,
          isInteractiveHost: isInteractiveHost,
          memberActionStream: memberActionStream,
        );
      },
    );
  }
}

class _AudienceBottomSheet extends ConsumerWidget {
  const _AudienceBottomSheet({
    required this.isInteractiveHost,
    required this.livekitConnected,
    this.memberActionStream
  });

  final bool isInteractiveHost;
  final bool livekitConnected;
  final StreamController<MemberActionDto>? memberActionStream;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(roomMembersProvider);
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F3F3),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  itemCount: members.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 22,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final item = members[index];
                    return _AudienceGridItem(
                      item: item,
                      livekitConnected: livekitConnected,
                      isInteractiveHost: isInteractiveHost,
                      memberActionStream: memberActionStream
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudienceGridItem extends StatelessWidget {
  const _AudienceGridItem({
    required this.item,
    required this.isInteractiveHost,
    required this.livekitConnected,
    this.memberActionStream
  });

  final LiveRoomMemberDto item;
  final bool isInteractiveHost;
  final bool livekitConnected;
  final StreamController<MemberActionDto>? memberActionStream;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(UserPrefs.getUserInfo()?.userId == item.userId) {
          return;
        }
        if(isInteractiveHost && livekitConnected) {
          memberActionStream?.add(MemberActionDto(memberAction: MemberAction.attemptToSendInvitation, memberInfo: item));
        } else {
          memberActionStream?.add(MemberActionDto(memberAction: MemberAction.attemptToKickout, memberInfo: item));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.network(
                    item.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const Icon(Icons.person, size: 28);
                    },
                  ),
                ),
              ),
              if (item.isHandsUp)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.back_hand_rounded,
                        size: 9,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      )
    );
  }
}
