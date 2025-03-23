import 'package:actpod_web/features/player_page/player_screen.dart';
import 'package:go_router/go_router.dart';

final myRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PlayerScreen(),
    ),
  ],
);