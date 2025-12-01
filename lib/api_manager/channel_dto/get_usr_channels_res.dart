import 'package:actpod_web/dto/channel_dto.dart';

class GetUserChannelsRes {
  String code;
  String message;
  List<ChannelDto>? channelInfoList;

  GetUserChannelsRes(this.code, this.message, this.channelInfoList);

  factory GetUserChannelsRes.fromJson(Map<String, dynamic> json) {
    return GetUserChannelsRes(
      json["code"],
      json["message"],
      json["data"]?.map<ChannelDto>((json) => ChannelDto.fromJson(json)).toList()
    );
  }
}