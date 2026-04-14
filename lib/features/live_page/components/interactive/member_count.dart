import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/features/live_page/components/member_bottom_sheet.dart';
import 'package:actpod_web/features/live_page/providers/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' as livekit_client;

class MemberCount extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(roomMembersProvider);

    return GestureDetector(
      onTap: () {
        MembersBottomSheet().show(
          context,
          isInteractiveHost: false,
          livekitConnected: ref.watch(livekitConnectionStateProvider) == livekit_client.ConnectionState.connected
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
              '${members.length} 人',
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