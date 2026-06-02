import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/dto/space_dto.dart';
import 'package:quick_share_app/router.dart';

import '../features/home_page_feature/providers.dart';
import '../features/space_selection_feature/providers.dart';

class PageRouterService {
  // static Future<void> homePageToSpaceStoryPage(WidgetRef ref, SpaceInfoDto space) async {
  //   router.push("/"); // let router.pop work
  //   ref.watch(homePageSelectedSpaceInfoProvider.notifier).state = space;
  //   ref.watch(homePageStateProvider.notifier).state = "space";
  // }
  //
  // static Future<void> spaceStoryPageToHomePage(WidgetRef ref) async {
  //   router.pop();
  //   ref.watch(homePageSelectedSpaceInfoProvider.notifier).state = null;
  //   ref.watch(homePageStateProvider.notifier).state = "recommended";
  // }
  //
  // static Future<void> spaceStoryPageToSelectionPage(WidgetRef ref) async {
  //   router.pop();
  //   ref.watch(spaceSelectionPageSelectedSpaceInfoProvider.notifier).state = null;
  //   ref.watch(spaceSelectionPageStateProvider.notifier).state = "selecting";
  // }
  //
  // static Future<void> selectionPageToSpaceStoryPage(WidgetRef ref, SpaceInfoDto space) async {
  //   router.push("/");
  //   ref.watch(spaceSelectionPageSelectedSpaceInfoProvider.notifier).state = space;
  //   ref.watch(spaceSelectionPageStateProvider.notifier).state = "space";
  // }
  //
  // static Future<void> homePageToOtherUserPage(WidgetRef ref, String userId) async {
  //   router.push("/");
  //   ref.watch(homePageSelectedUserProvider.notifier).state = userId;
  //   ref.watch(homePageStateProvider.notifier).state = "otherUser";
  // }
  //
  // static Future<void> otherUserPageToHomePage(WidgetRef ref) async {
  //   router.pop();
  //   ref.watch(homePageSelectedUserProvider.notifier).state = null;
  //   ref.watch(homePageStateProvider.notifier).state = "recommended";
  // }
  //
  // static Future<void> spaceStoryPageToOtherUserPage(WidgetRef ref) async {
  //
  // }
}