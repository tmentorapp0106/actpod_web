import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_share_app/dto/channel_collection_dto.dart';
import 'package:quick_share_app/dto/story_recommendation_dto.dart';
import 'package:flutter_riverpod/legacy.dart';

final collectionListProvider = StateProvider.autoDispose<List<ChannelCollectionDto>?>((ref) => null);
final collectionStoryListProvider = StateProvider.autoDispose<List<RecommendationItem>?>((ref) => null);