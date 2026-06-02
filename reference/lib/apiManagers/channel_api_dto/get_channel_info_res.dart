import 'package:quick_share_app/dto/channel_dto.dart';

class GetChannelInfoRes {
  String code;
  String message;
  ChannelDto? channelInfo;

  GetChannelInfoRes(this.code, this.message, this.channelInfo);

  factory GetChannelInfoRes.fromJson(Map<String, dynamic> json) {
    return GetChannelInfoRes(
        json["code"],
        json["message"],
        json["data"] == null? null : ChannelDto.fromJson(json["data"])
    );
  }
}