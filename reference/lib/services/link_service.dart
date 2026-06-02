import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:quick_share_app/services/upgrade_service.dart';
import 'package:quick_share_app/services/user_service.dart';

import '../apiManagers/story_api_dto/get_one_story_res.dart';
import '../apiManagers/story_system_api_manager.dart';
import '../dto/player_item_dto.dart';
import '../features/live_feature/dto/purchase_ticket_enum.dart';
import '../features/login_feature/login_screen.dart';
import '../router.dart';

final appLinks = AppLinks();

class LinkService {
  static Future<void> initUniLinks() async {
    appLinks.uriLinkStream.listen(
      (uri) async {
        await Future.delayed(const Duration(milliseconds: 1500));// wait for home page finish render
        if(!await UpgradeService.check()) {
          return;
        }

        final paths = uri.path.split("/");
        if(paths[1] == "live") {
          if(!UserService.hasLoggedIn()) {
            showDialog(
              context: shellNavigatorKey.currentContext!,
              builder: (context) {
                return LoginPageScreen();
              }
            );
            return;
          }

          if(paths.length < 5) {
            return;
          }
          final type = paths[3];
          final roomId = paths[4];
          final storyId = paths[5];
          if(type == "listen_together") {
            final result = await router.push("/live/listen_together/audience/$roomId/$storyId");
            if (result != null && result == PurchaseTicketEnum.notEnough) {
              router.push("/purchase");
            }
          } else if(type == "interactive") {
            final result = await router.push("/live/interactive/audience/$roomId/$storyId");
            if (result != null && result == PurchaseTicketEnum.notEnough) {
              router.push("/purchase");
            }
          }
        } else {
          await Future.delayed(const Duration(milliseconds: 2000)); // wait for home page finish render
          GetOneStoryRes storyRes = await storyApiManager.getOneStory(uri.path.split("/").last);
          if(storyRes.code != "0000") {
            return;
          }
          PlayerItemDto playItem = PlayerItemDto.fromGetOneStoryResItem(storyRes.story!);
          List<PlayerItemDto> playList = [playItem];
          router.push("/story/multiple", extra: {"playerItemList": playList, "index": 0});
        }
      },
    );
  }
}