import 'package:quick_share_app/dto/ending_list_item_dto.dart';

class GetEndingListRes {
  String code;
  String message;
  List<EndingListItemDto> data;

  GetEndingListRes(this.code, this.message, this.data);

  factory GetEndingListRes.fromJson(Map<String, dynamic> json) {
    return GetEndingListRes(json["code"], json["message"], json["data"]?.map<EndingListItemDto>((json) => EndingListItemDto.fromJson(json)).toList());
  }
}