import 'package:flutter_riverpod/legacy.dart';
import 'package:quick_share_app/dto/announcement_dto.dart';
import 'package:quick_share_app/dto/space_dto.dart';
import 'package:quick_share_app/dto/story_recommendation_dto.dart';

import '../../dto/live_room_dto.dart';


final recommendationListProvider = StateProvider<List<RecommendationItem>>((ref) => []);
final spaceListProvider = StateProvider<List<SpaceInfoDto>>((ref) => []);

final announcementProvider = StateProvider<List<AnnouncementDto>?>((ref) => null);

final currentBannerIndicatorProvider = StateProvider<int>((ref) => 0);
final bannerUrlProvider = StateProvider<List<String>>((ref) => []);

final activeRoomsProvider = StateProvider<List<LiveRoomDto>>((ref) => []);


