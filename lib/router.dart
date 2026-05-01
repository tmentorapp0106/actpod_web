import 'package:actpod_web/features/home_page/home_screen.dart';
import 'package:actpod_web/features/live_page/screens/interactive_screen.dart';
import 'package:actpod_web/features/live_page/screens/listen_only_screen.dart';
import 'package:actpod_web/features/personal_page/personal_screen.dart';
import 'package:actpod_web/features/player_page/player_screen.dart';
import 'package:actpod_web/features/podcast_store_page/podcast_store_page.dart';
import 'package:actpod_web/features/tappay_checkout_page/tappay_checkout_page.dart';
import 'package:go_router/go_router.dart';

final myRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: "/story/:storyId",
      builder: (context, state) {
        return PlayerScreen(state.pathParameters["storyId"]!);
      },
    ),
    GoRoute(
      path: "/personal/:userId",
      builder: (context, state) {
        return PersonalScreen(userId: state.pathParameters["userId"]!);
      },
    ),
    GoRoute(
      path: "/live/interactive/:roomId/:storyId",
      builder: (context, state) {
        return InteractiveScreen(roomId: state.pathParameters["roomId"]!, storyId: state.pathParameters["storyId"]!);
      },
    ),
    GoRoute(
      path: "/live/listenOnly/:roomId/:storyId",
      builder: (context, state) {
        return ListenOnlyScreen(roomId: state.pathParameters["roomId"]!, storyId: state.pathParameters["storyId"]!);
      },
    ),
    GoRoute(
      path: "/merchant",
      builder: (context, state) {
        return const TapPayCheckoutPage();
      },
    ),
    GoRoute(
      path: "/podcast_store/:userId",
      builder: (context, state) {
        return PodcastStoreScreen(userId: state.pathParameters["userId"]!);
      },
    )
  ],
);