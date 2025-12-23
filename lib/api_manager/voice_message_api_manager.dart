import 'package:actpod_web/api_manager/abstractApiManager.dart';
import 'package:actpod_web/api_manager/voice_message_dto/get_interactive_content_res.dart';
import 'package:dio/dio.dart';

final voiceMessageApiManager = VoiceMessageApiManager(systemName: "VOICE_MESSAGE_SERVER_URL");

class VoiceMessageApiManager extends AbstractApiManager {
  VoiceMessageApiManager({required String systemName}) : super(systemName: systemName);

  Future<GetInteractiveContentRes> getInteractiveContent(String storyId) async {
    Response response = await handelGet("/interactiveContent/$storyId");
    return GetInteractiveContentRes.fromJson(response.data);
  }
}