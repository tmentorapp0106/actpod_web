import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/features/live_feature/components/members_bottom_sheet.dart';
import 'package:livekit_client/livekit_client.dart' as livekit_client;

import '../../../../../design_system/color.dart';
import '../../../dto/mic_action_dto.dart';
import '../../../providers.dart';

class MemberCount extends ConsumerWidget {
  final StreamController<MemberActionDto>? memberActionStream;

  MemberCount({required this.memberActionStream});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(roomMembersProvider);
    final roomInfo = ref.watch(roomInfoProvider);

    return GestureDetector(
      onTap: () {
        MembersBottomSheet().show(
          context,
          livekitConnected: ref.watch(livekitConnectionStateProvider) == livekit_client.ConnectionState.connected,
          isInteractiveHost: true,
          memberActionStream: memberActionStream
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: DesignColor.actpodPrimary50,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_alt_rounded,
              size: 16,
              color: DesignColor.actpodPrimary500,
            ),
            const SizedBox(width: 2),
            Text(
              '${members.length} / ${roomInfo?.capacity?? 0} 人',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: DesignColor.actpodPrimary500,
              ),
            ),
          ],
        ),
      )
    );
  }
}