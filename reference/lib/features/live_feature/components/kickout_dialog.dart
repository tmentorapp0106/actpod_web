import 'package:flutter/material.dart';
import 'package:quick_share_app/components/avatar.dart';

import '../../../dto/live_room_member_dto.dart';

class KickoutDialog extends StatelessWidget {
  final LiveRoomMemberDto memberInfo;
  final VoidCallback onKickOutRoom;

  const KickoutDialog({
    super.key,
    required this.memberInfo,
    required this.onKickOutRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 260,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Center(
                      child: Row(
                          children: [
                            Avatar(null, memberInfo.avatarUrl, 26),
                            const SizedBox(width: 8,),
                            Text(
                              memberInfo.nickname,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ]
                      )
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    size: 28,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _OptionItem(
              text: '踢出房間',
              onTap: () {
                Navigator.of(context).pop();
                onKickOutRoom();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _OptionItem({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ]
              ),
            ),
          )
      ),
    );
  }
}