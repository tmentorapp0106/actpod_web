import 'package:flutter/material.dart';
import 'package:quick_share_app/design_system/color.dart';

import '../../../dto/live_room_background_music_dto.dart';
import '../dto/background_option_dto.dart';


class BackgroundMusicBottomSheet {
  Future<BackgroundOptionDto?> showOptionBottomSheet({
    required BuildContext context,
    required List<LiveRoomBackgroundMusicDto> options,
  }) async {
    return await showModalBottomSheet<BackgroundOptionDto>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              ...options.map((option) {
                return InkWell(
                  onTap: () => Navigator.pop(
                    context,
                    BackgroundOptionDto(
                      musicDto: option,
                      newMusic: false,
                      stopMusic: false,
                    ),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          color: DesignColor.actpodPrimary400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          option.name,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    )
                  ),
                );
              }),

              InkWell(
                onTap: () => Navigator.pop(
                  context,
                  BackgroundOptionDto(
                    musicDto: null,
                    newMusic: true,
                    stopMusic: false,
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: DesignColor.neutral500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "新增背景音樂",
                        style: TextStyle(fontSize: 16),
                      ),
                    ]
                  )
                ),
              ),

              InkWell(
                onTap: () => Navigator.pop(
                  context,
                  BackgroundOptionDto(
                    musicDto: null,
                    newMusic: false,
                    stopMusic: true,
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.stop_rounded,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "停止背景音樂",
                        style: TextStyle(fontSize: 16),
                      ),
                    ]
                  )
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}