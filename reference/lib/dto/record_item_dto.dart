
import '../apiManagers/recommendation_api_dto/get_record_for_record_wall_res.dart';

class RecordItemDto {
  String recordId;
  String recordUrl;
  String channelId;
  String channelName;
  String recordName;
  String recordDescription;
  String? channelImageUrl;
  bool openVoiceMessage;

  RecordItemDto(this.recordId, this.recordUrl, this.channelId, this.channelName, this.recordName, this.recordDescription, this.channelImageUrl, this.openVoiceMessage);


  factory RecordItemDto.fromGetRecordWallRecordsResItem(GetRecordWallRecordsResItem getRecordWallRecordsResItem) {
    return RecordItemDto(
      getRecordWallRecordsResItem.recordId,
      getRecordWallRecordsResItem.recordUrl,
      getRecordWallRecordsResItem.channelId,
      getRecordWallRecordsResItem.channelName,
      getRecordWallRecordsResItem.recordName,
      getRecordWallRecordsResItem.recordDescription,
      getRecordWallRecordsResItem.channelImageUrl,
      getRecordWallRecordsResItem.openVoiceMessage
    );
  }
}