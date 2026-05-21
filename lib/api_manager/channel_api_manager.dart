import 'package:actpod_web/api_manager/abstractApiManager.dart';
import 'package:actpod_web/api_manager/channel_dto/create_collection_res.dart';
import 'package:actpod_web/api_manager/channel_dto/delete_collection_res.dart';
import 'package:actpod_web/api_manager/channel_dto/exist_collection_res.dart';
import 'package:actpod_web/api_manager/channel_dto/get_usr_channels_res.dart';
import 'package:actpod_web/api_manager/purchase_dto/get_podcast_stoer.dart';
import 'package:dio/dio.dart';

final channelApiManager = ChannelApiManager(systemName: "CHANNEL_SERVER_URL");

class ChannelApiManager extends AbstractApiManager {

  ChannelApiManager({required String systemName}) : super(systemName: systemName);


  Future<GetUserChannelsRes> getUserChannels(String userId) async {
    Response response = await handelGet("/channel/user/$userId");
    return GetUserChannelsRes.fromJson(response.data);
  }

  Future<GetPodcastStoreRes> getPodcastStore(String userId) async {
    Response response = await handelGet("/podcastStore/user/$userId");
    return GetPodcastStoreRes.fromJson(response.data);
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
}