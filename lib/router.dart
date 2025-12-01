import 'package:actpod_web/features/home_page/home_screen.dart';
import 'package:actpod_web/features/personal_page/personal_screen.dart';
import 'package:actpod_web/features/player_page/player_screen.dart';
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
    )
  ],
);