import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_share_app/dto/player_item_dto.dart';
import 'package:quick_share_app/dto/space_dto.dart';
import 'package:quick_share_app/features/block_user_feature/block_user_screen.dart';
import 'package:quick_share_app/features/channel_collection_feature/screens/channel_collection_screen.dart';
import 'package:quick_share_app/features/channel_page_feature/screens/channel_screen.dart';
import 'package:quick_share_app/features/home_page_feature/home_page_screen.dart';
import 'package:quick_share_app/features/live_feature/screens/listen_together/audience_listen_together_screen.dart';
import 'package:quick_share_app/features/live_feature/screens/listen_together/host_listen_together_screen.dart';
import 'package:quick_share_app/features/live_feature/screens/live_rooms_screen.dart';
import 'package:quick_share_app/features/purchase_feature/purchase_screen.dart';
import 'package:quick_share_app/features/report_feature/report_screen.dart';
import 'package:quick_share_app/features/search_page_feature/search_page_screen.dart';
import 'package:quick_share_app/features/space_selection_feature/space_selection_screen.dart';
import 'package:quick_share_app/features/update_story_feature/update_story_screen.dart';
import 'package:quick_share_app/features/user_info_feature/screens/other_user_info_screen.dart';
import 'package:quick_share_app/features/user_info_feature/screens/subscription_screen.dart';
import 'package:quick_share_app/features/user_info_feature/screens/user_info_screen.dart';
import 'package:quick_share_app/features/voice_message_notice_page_feature/voice_message_notice_page_screen.dart';
import 'package:quick_share_app/features/withdraw_feature/withdraw_screen.dart';
import 'package:quick_share_app/main.dart';
import 'package:quick_share_app/providers.dart';
import 'package:quick_share_app/route_observer.dart';

import 'features/live_feature/screens/interactive/audience_interactive_screen.dart';
import 'features/live_feature/screens/interactive/host_interactive_screen.dart';
import 'features/main_page_feature/main_page.dart';
import 'features/play_record_feature/screens/play_record_screen.dart';
import 'features/record_feature/screens/record_screen.dart';
import 'features/shorts_feature/shorts_screen.dart';
import 'features/space_story_feature/space_story_screen.dart';
import 'features/voice_message_page_feature/voice_message_page_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: "/",
  observers: [
    MyRouteObserver(),
    routeObserver,
  ],
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) =>
          MainPageScreen(child),
      routes: [
        GoRoute(
          path: "/",
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return HomePageScreen(scrollController: homePageScrollController);
          },
        ),
        GoRoute( // still need this for routing, but :storyId will be extracted at link service
          path: "/story/link/:storyId",
          builder: (context, state) {
            return HomePageScreen(scrollController: homePageScrollController);
          },
        ),
        GoRoute( // still need this for routing, but :storyId will be extracted at link service
          path: "/live/link/:type/:roomId/:storyId",
          builder: (context, state) {
            return HomePageScreen(scrollController: homePageScrollController);
          },
        ),
        GoRoute(
          path: "/spaceStory",
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return SpaceStoryScreen(state.extra as SpaceInfoDto);
          },
        ),
        GoRoute(
          path: "/spaceSelection",
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return SpaceSelectionScreen();
          },
        ),
        GoRoute(
          path: "/search",
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return SearchPageScreen();
          },
        ),
        GoRoute(
          path: "/voiceMessageNotice",
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return VoiceMessageNoticePageScreen();
          }
        ),
        GoRoute(
          path: "/userInfo",
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return UserInfoScreen();
          }
        ),
        GoRoute(
          path: "/live_rooms",
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return LiveRoomsScreen();
          },
        ),
        GoRoute(
          path: "/shorts",
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return ShortsScreen();
          },
        ),
        GoRoute(
          path: "/collection",
          parentNavigatorKey: shellNavigatorKey,
          builder: (context, state) {
            return ChannelCollectionScreen();
          },
        )
      ]
    ),
    GoRoute(
      path: "/channel/:channelId",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return ChannelScreen(state.pathParameters["channelId"]!);
      },
    ),
    GoRoute(
      path: "/otherUserInfo/:userId",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return OtherUserInfoScreen(state.pathParameters["userId"]!);
      },
    ),
    GoRoute(
      path: "/record",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return const RecordScreen();
      }
    ),
    GoRoute(
      path: "/story/:storyId/update",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return UpdateStoryScreen(state.pathParameters["storyId"]!);
      }
    ),
    GoRoute(
      path: "/live/listen_together/audience/:roomId/:storyId",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        actPodAudioHandler?.pause();
        return AudienceListenTogetherScreen(
          roomId: state.pathParameters["roomId"]!,
          storyId: state.pathParameters["storyId"]!
        );
      }
    ),
    GoRoute(
      path: "/live/listen_together/host/:storyId",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        actPodAudioHandler?.pause();
        Map<String, Object>? extraMap = state.extra as Map<String, Object>?;
        return HostListenTogetherScreen(
          roomId: extraMap!["roomId"] as String,
          storyId: state.pathParameters["storyId"]!,
          title: extraMap["title"] as String,
          notifyFans: extraMap["notifyFans"] as bool,
          notyetOwnedStoryPrice: extraMap["notyetOwnedStoryPrice"] as int,
          alreadyOwnedStoryPrice: extraMap["alreadyOwnedStoryPrice"] as int
        );
      }
    ),
    GoRoute(
        path: "/live/interactive/audience/:roomId/:storyId",
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          actPodAudioHandler?.pause();
          return AudienceInteractiveScreen(
            roomId: state.pathParameters["roomId"]!,
            storyId: state.pathParameters["storyId"]!,
          );
        }
    ),
    GoRoute(
      path: "/live/interactive/host/:storyId",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        actPodAudioHandler?.pause();
        Map<String, Object?>? extraMap = state.extra as Map<String, Object?>?;
        return HostInteractiveScreen(
          roomId: extraMap!["roomId"] as String,
          storyId: state.pathParameters["storyId"]!,
          title: extraMap["title"] as String,
          capacity: extraMap["capacity"] as int,
          notifyFans: extraMap["notifyFans"] as bool,
            notyetOwnedStoryPrice: extraMap["notyetOwnedStoryPrice"] as int,
            alreadyOwnedStoryPrice: extraMap["alreadyOwnedStoryPrice"] as int
        );
      }
    ),
    GoRoute(
      path: "/purchase",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return PurchaseScreen();
      }
    ),
    GoRoute(
        path: "/subscribe",
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          return SubscriptionScreen();
        }
    ),
    GoRoute(
        path: "/withdraw",
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          return WithdrawScreen();
        }
    ),
    GoRoute(
      path: "/voiceMessage/story/:storyId/owner/:ownerId/collaborator/:collaboratorId",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        String collaboratorId = state.pathParameters["collaboratorId"]! == "null"? "" : state.pathParameters["collaboratorId"]!;
        return VoiceMessagePageScreen(state.pathParameters["storyId"]!, state.pathParameters["ownerId"]!, collaboratorId);
      }
    ),
    GoRoute(
      path: "/report",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        return const ReportScreen();
      }
    ),
    GoRoute(
        path: "/block",
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          return const BlockUserScreen();
        }
    ),
    GoRoute(
      path: "/story/multiple",
      redirect: (context, state) {
        // Check if the `extra` field is null
        if (state.extra == null) {
          return "/";
        }
        return null; // Proceed normally if extra is not null
      },
      pageBuilder: (context, state) {
        Map<String, Object>? extraMap = state.extra as Map<String, Object>?;

        List<PlayerItemDto> playerItemList = extraMap!["playerItemList"] as List<PlayerItemDto>;
        int index = extraMap["index"] as int;

        // 這裡定義您的目標 Widget
        Widget targetPage = (playerItemList[index].storyId == actPodAudioHandler?.mediaItem.value?.id)
            ? PlayRecordScreen(playerItemList, index, false)
            : PlayRecordScreen(playerItemList, index, true);

        if(Platform.isIOS) {
          return CupertinoPage(
            key: state.pageKey, // 保持 go_router 的 key
            child: targetPage,
          );
        } else {
          return MaterialPage(
            key: state.pageKey, // 保持 go_router 的 key
            child: targetPage,
          );
        }
      },
    ),
  ],
);