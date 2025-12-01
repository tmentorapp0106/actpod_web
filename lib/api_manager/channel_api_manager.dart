import 'package:actpod_web/api_manager/abstractApiManager.dart';
import 'package:actpod_web/api_manager/channel_dto/get_usr_channels_res.dart';
import 'package:dio/dio.dart';

final channelApiManager = ChannelApiManager(systemName: "CHANNEL_SERVER_URL");

class ChannelApiManager extends AbstractApiManager {

  ChannelApiManager({required String systemName}) : super(systemName: systemName);


  Future<GetUserChannelsRes> getUserChannels(String userId) async {
    Response response = await handelGet("/user/$userId");
    return GetUserChannelsRes.fromJson(response.data);
  }
}