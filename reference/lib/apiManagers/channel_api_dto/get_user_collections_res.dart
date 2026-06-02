import 'package:quick_share_app/dto/channel_collection_dto.dart';

class GetUserCollectionRes {
  String code;
  String message;
  List<ChannelCollectionDto>? channelCollectionList;

  GetUserCollectionRes(this.code, this.message, this.channelCollectionList);

  factory GetUserCollectionRes.fromJson(Map<String, dynamic> json) {
    return GetUserCollectionRes(
        json["code"],
        json["message"],
        json["data"]?.map<ChannelCollectionDto>((json) => ChannelCollectionDto.fromJson(json)).toList()
    );
  }
}