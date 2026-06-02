import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/check_capacity_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/create_collection_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/delete_collection_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/exist_collection_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/exist_podcast_store_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/get_channel_info_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/get_podcast_store_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/get_user_channels_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/get_user_collections_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/update_channel_res.dart';
import 'package:quick_share_app/apiManagers/channel_api_dto/update_podcast_store_res.dart';

import '../features/podcast_store_feature/dto/link_form_item.dart';
import 'abstractApiManager.dart';
import 'channel_api_dto/create_channel_res.dart';
import 'channel_api_dto/create_podcast_store_res.dart';
import 'channel_api_dto/delete_channel_res.dart';
import 'channel_api_dto/get_user_collection_stories_res.dart';
import 'channel_api_dto/search_channel_res.dart';

final channelApiManager = ChannelApiManager(systemName: "CHANNEL_SERVER_URL");

class ChannelApiManager extends AbstractApiManager {

  ChannelApiManager({required String systemName}) : super(systemName: systemName);

  Future<CheckCapacityRes> checkCapacity() async {
    Response response = await handelPostWithUserToken("/channel/checkCapacity", null);
    return CheckCapacityRes.fromJson(response.data);
  }

  Future<GetChannelInfoRes> getChannelInfo(String channelId) async {
    Response response = await handelGet("/channel/$channelId");
    return GetChannelInfoRes.fromJson(response.data);
  }

  Future<GetUserChannelsRes> getUserChannels(String userId) async {
    Response response = await handelGet("/channel/user/$userId");
    return GetUserChannelsRes.fromJson(response.data);
  }

  Future<CreateChannelRes> createChannel(String channelName, String channelDescription, String channelImageUrl, List<String> coOwners) async {
    var postData = {
      "channelName": channelName,
      "channelDescription": channelDescription,
      "channelImageUrl": channelImageUrl,
      "coOwners": coOwners
    };

    Response response = await handelPostWithUserToken("/channel", postData);
    return CreateChannelRes.fromJson(response.data);
  }

  Future<SearchChannelRes> searchChannel(String channelName) async {
    var postData = {
      "channelName": channelName
    };

    Response response = await handelPost("/channel/search", postData);
    return SearchChannelRes.fromJson(response.data);
  }

  Future<UpdateChannelRes> updateChannel(String channelId, String name, String description, String imageUrl, List<String> coOwners) async {
    var data = {
      "channelId": channelId,
      "channelName": name,
      "channelDescription": description,
      "channelImageUrl": imageUrl,
      "coOwners": coOwners
    };

    Response response = await handelPostWithUserToken("/channel/update", data);
    return UpdateChannelRes.fromJson(response.data);
  }

  Future<DeleteChannelRes> deleteChannel(String channelId) async {
    var data = {
      "channelId": channelId,
    };

    Response response = await handelPostWithUserToken("/channel/delete", data);
    return DeleteChannelRes.fromJson(response.data);
  }

  Future<CreateCollectionRes> createChannelCollection(String channelId) async {
    var data = {
      "channelId": channelId
    };
    
    Response response = await handelPostWithUserToken("/channel/collection", data);
    return CreateCollectionRes.fromJson(response.data);
  }

  Future<DeleteCollectionRes> deleteChannelCollection(String channelId) async {
    var data = {
      "channelId": channelId
    };

    Response response = await handelPostWithUserToken("/channel/collection/archive", data);
    return DeleteCollectionRes.fromJson(response.data);
  }
  
  Future<ExistCollectionRes> existChannelCollection(String channelId) async {
    Response response = await handelGetWithUserToken("/channel/collection/channel/$channelId/exist");
    return ExistCollectionRes.fromJson(response.data);
  }
  
  Future<GetUserCollectionRes> getUserCollections() async {
    Response response = await handelGetWithUserToken("/channel/collections");
    return GetUserCollectionRes.fromJson(response.data);
  }

  Future<GetUserCollectionStoriesRes> getUserCollectionStories() async {
    Response response = await handelGetWithUserToken("/channel/collections/stories");
    return GetUserCollectionStoriesRes.fromJson(response.data);
  }

  Future<CreatePodcastStoreRes> createPodcastStore(
    String name,
    String description,
    String storeImageUrl,
    String instagramUrl,
    String facebookUrl,
    String threadsUrl,
    String youtubeUrl,
    List<LinkFormItem> links
  ) async {
    var data = {
      "name": name,
      "description": description,
      "storeImageUrl": storeImageUrl,
      "instagramUrl": instagramUrl,
      "facebookUrl": facebookUrl,
      "threadsUrl": threadsUrl,
      "youtubeUrl": youtubeUrl,
      "links": links
          .where((e) => e.urlController.text.trim().isNotEmpty ||
          (e.imageUrl?.trim().isNotEmpty ?? false))
          .map((e) => e.toJson())
          .toList(),
    };

    Response response = await handelPostWithUserToken("/podcastStore", data);
    return CreatePodcastStoreRes.fromJson(response.data);
  }

  Future<GetPodcastStoreRes> getPodcastStore(String userId) async {
    Response response = await handelGet("/podcastStore/user/$userId");
    return GetPodcastStoreRes.fromJson(response.data);
  }

  Future<UpdatePodcastStoreRes> updatePodcastStore(
      String name,
      String description,
      String storeImageUrl,
      String instagramUrl,
      String facebookUrl,
      String threadsUrl,
      String youtubeUrl,
      List<LinkFormItem> links
      ) async {
    var data = {
      "name": name,
      "description": description,
      "storeImageUrl": storeImageUrl,
      "instagramUrl": instagramUrl,
      "facebookUrl": facebookUrl,
      "threadsUrl": threadsUrl,
      "youtubeUrl": youtubeUrl,
      "links": links
          .where((e) => e.urlController.text.trim().isNotEmpty ||
          (e.imageUrl?.trim().isNotEmpty ?? false))
          .map((e) => e.toJson())
          .toList(),
    };

    Response response = await handelPostWithUserToken("/podcastStore/update", data);
    return UpdatePodcastStoreRes.fromJson(response.data);
  }

  Future<ExistPodcastStoreRes> existPodcastStore(String userId) async {
    Response response = await handelGet("/podcastStore/user/$userId/exists");
    return ExistPodcastStoreRes.fromJson(response.data);
  }
}