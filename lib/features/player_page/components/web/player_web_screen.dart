import 'dart:async';

import 'package:actpod_web/api_manager/story_dto/get_one_story_res.dart';
import 'package:actpod_web/components/avatar.dart';
import 'package:actpod_web/components/channel_image.dart';
import 'package:actpod_web/components/content_rating_badge.dart';
import 'package:actpod_web/components/launch_deep_link_dialog.dart';
import 'package:actpod_web/design_system/shadow.dart';
import 'package:actpod_web/features/login/login_screen.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobiel_collect_button.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_comment_list_model.dart';
import 'package:actpod_web/features/player_page/components/mobile/mobile_instant_comment_list_model.dart';
import 'package:actpod_web/features/player_page/controllers/collection_controller.dart';
import 'package:actpod_web/features/player_page/controllers/comment_controller.dart';
import 'package:actpod_web/features/player_page/controllers/player_controller.dart';
import 'package:actpod_web/features/player_page/providers.dart';
import 'package:actpod_web/features/player_page/service/story_purchase_service.dart';
import 'package:actpod_web/local_storage/user_info.dart';
import 'package:actpod_web/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:actpod_web/design_system/color.dart';
import 'package:actpod_web/utils/time_utils.dart';

part 'web_header.dart';
part 'web_story_card.dart';
part 'web_account_button.dart';
part 'web_action_button.dart';
part 'web_deep_link.dart';
part 'web_download_card.dart';
part 'web_player_dock.dart';
part 'web_story_info.dart';
part 'web_media_panel.dart';
part 'web_side_cards.dart';

class PlayerWebScreen extends StatelessWidget {
  final CollectionController collectionController;
  final PlayerController playerController;
  final CommentController commentController;
  final FocusNode commentFocusNode;
  final FocusNode instantCommentFocusNode;
  final String storyId;

  const PlayerWebScreen({
    super.key,
    required this.collectionController,
    required this.playerController,
    required this.commentController,
    required this.commentFocusNode,
    required this.instantCommentFocusNode,
    required this.storyId,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 116),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  children: [
                    _WebHeader(playerController: playerController),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final sideColumn = Column(
                          children: [
                            _WebAboutCard(),
                            const SizedBox(height: 16),
                            _WebCommentCard(
                              commentController: commentController,
                              focusNode: commentFocusNode,
                            ),
                            const SizedBox(height: 16),
                            const _WebDownloadCard(),
                          ],
                        );

                        final storyCard = _WebStoryCard(
                          collectionController: collectionController,
                          playerController: playerController,
                          commentController: commentController,
                          commentFocusNode: commentFocusNode,
                          instantCommentFocusNode: instantCommentFocusNode,
                          storyId: storyId,
                        );

                        if (constraints.maxWidth < 960) {
                          return Column(
                            children: [
                              storyCard,
                              const SizedBox(height: 18),
                              sideColumn,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: storyCard),
                            const SizedBox(width: 24),
                            Expanded(flex: 4, child: sideColumn),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: _WebPlayerDock(playerController: playerController),
        ),
      ],
    );
  }
}
