import 'package:quick_share_app/dto/opening_list_item_dto.dart';

class GetOpeningListRes {
  String code;
  String message;
  List<OpeningListItemDto> data;

  GetOpeningListRes(this.code, this.message, this.data);

  factory GetOpeningListRes.fromJson(Map<String, dynamic> json) {
    return GetOpeningListRes(json["code"], json["message"], json["data"]?.map<OpeningListItemDto>((json) => OpeningListItemDto.fromJson(json)).toList());
  }
}