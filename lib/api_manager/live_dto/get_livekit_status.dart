import 'package:actpod_web/features/live_page/dto/livekit_status.dart';

class GetLivekitStatusRes {
  String code;
  String message;
  LivekitStatusDto status;

  GetLivekitStatusRes(this.code, this.message, this.status);

  factory GetLivekitStatusRes.fromJson(Map<String, dynamic> json) {
    return GetLivekitStatusRes(
      (json['code'] ?? '') as String,
      (json['message'] ?? '') as String,
      LivekitStatusDto.fromJson(
        (json['data'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
    );
  }
}