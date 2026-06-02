import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/add_voice_message_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/get_interactive_content_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/get_voice_message_notice.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/get_voice_message_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/get_voice_message_stat_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/transcribe_voice_message_res.dart';
import 'package:quick_share_app/apiManagers/voice_message_api_dto/update_voice_message_stat_res.dart';
import 'package:quick_share_app/dto/interactive_content_dto.dart';

import 'abstractApiManager.dart';
import 'voice_message_api_dto/send_voice_message_res.dart';

final voiceMessageApiManager = VoiceMessageApiManager(systemName: "VOICE_MESSAGE_SERVER_URL");

class VoiceMessageApiManager extends AbstractApiManager {

  VoiceMessageApiManager({required String systemName}) : super(systemName: systemName);

  Future<SendVoiceMessageRes> sendVoiceMessage(
    String storyId,
    String url,
    Duration length,
    int donateAmount,
    String acceptAdd
  ) async {
    var data = {
      "storyId": storyId,
      "url": url,
      "length": length.inMilliseconds,
      "donateAmount": donateAmount,
      "acceptAdd": acceptAdd
    };

    Response response = await handelPostWithUserToken("", data);
    return SendVoiceMessageRes.fromJson(response.data);
  }

  Future<SendVoiceMessageRes> sendDirectVoiceMessage(String storyId, String url) async {
    var data = {
      "storyId": storyId,
      "url": url,
    };

    Response response = await handelPostWithUserToken("/direct", data);
    return SendVoiceMessageRes.fromJson(response.data);
  }

  Future<SendVoiceMessageRes> listenerSendResponse(String storyId, String voiceMessageId, String url, Duration length) async {
    var data = {
      "voiceMessageId": voiceMessageId,
      "storyId": storyId,
      "url": url,
      "length": length.inMilliseconds
    };

    Response response = await handelPostWithUserToken("/response/listener/", data);
    return SendVoiceMessageRes.fromJson(response.data);
  }

  Future<SendVoiceMessageRes> storyOwnerSendResponse(String storyId, String voiceMessageId, String url, Duration length) async {
    var data = {
      "voiceMessageId": voiceMessageId,
      "storyId": storyId,
      "url": url,
      "length": length.inMilliseconds
    };

    Response response = await handelPostWithUserToken("/response/storyOwner/", data);
    return SendVoiceMessageRes.fromJson(response.data);
  }

  Future<SendVoiceMessageRes> collaboratorSendResponse(String storyId, String voiceMessageId, String url, Duration length) async {
    var data = {
      "voiceMessageId": voiceMessageId,
      "storyId": storyId,
      "url": url,
      "length": length.inMilliseconds
    };

    Response response = await handelPostWithUserToken("/response/collaborator/", data);
    return SendVoiceMessageRes.fromJson(response.data);
  }

  Future<GetVoiceMessageRes> getStoryVoiceMessage(String storyId) async {
    Response response = await handelGetWithUserToken("/story/$storyId");
    return GetVoiceMessageRes.fromJson(response.data);
  }

  Future<GetVoiceMessageRes> getStoryVoiceMessageWithUserId(String storyId, String userId) async {
    Response response = await handelGetWithUserToken("/story/$storyId?userId=$userId");
    return GetVoiceMessageRes.fromJson(response.data);
  }

  Future<GetVoiceMessageNoticeRes> getUserVoiceMessageNotice(String filterType) async {
    Response response = await handelGetWithUserToken("/voiceMessageNotice/user?filterType=$filterType");
    return GetVoiceMessageNoticeRes.fromJson(response.data);
  }

  Future<AddVoiceMessageRes> addVoiceMessage(
    String storyId,
    String voiceMessageId,
    String concatedMessageUrl,
    String? preMessageUrl,
    String? afterMessageUrl
  ) async {
    var data = {
      "storyId": storyId,
      "voiceMessageId": voiceMessageId,
      "concatedMessageUrl": concatedMessageUrl,
      "preMessageUrl": preMessageUrl?? "",
      "afterMessageUrl": afterMessageUrl?? ""
    };
    Response response = await handelPostWithUserToken("/add", data);
    return AddVoiceMessageRes.fromJson(response.data);
  }

  Future<GetVoiceMessageRes> getVoiceMessages(int page, int pageSize) async {
    Response response = await handelGetWithUserToken("/voiceMessage/all?page=${page.toString()}&pageSize=${pageSize.toString()}");
    return GetVoiceMessageRes.fromJson(response.data);
  }

  Future<GetVoiceMessageRes> getStoryVoiceMessages(String storyId, int page, int pageSize) async {
    Response response = await handelGetWithUserToken("/voiceMessage/story?page=${page.toString()}&pageSize=${pageSize.toString()}&storyId=$storyId");
    return GetVoiceMessageRes.fromJson(response.data);
  }
  
  Future<GetVoiceMessageStatRes> getVoiceMessageStat(String storyId) async {
    Response response = await handelGet("/voiceMessage/stat/story/$storyId");
    return GetVoiceMessageStatRes.fromJson(response.data);
  }

  Future<UpdateVoiceMessageStatRes> updateVoiceMessageStat(String storyId, String status) async {
    var data = {
      "storyId": storyId,
      "status": status
    };
    Response response = await handelPostWithUserToken("/voiceMessage/stat/update", data);
    return UpdateVoiceMessageStatRes.fromJson(response.data);
  }

  Future<GetInteractiveContentRes> getInteractiveContent(String storyId) async {
    Response response = await handelGet("/interactiveContent/$storyId");
    return GetInteractiveContentRes.fromJson(response.data);
  }

  Future<TranscribeVoiceMessageRes> transcribeVoiceMessage(String voiceMessageId) async {
    var data = {
      "voiceMessageId": voiceMessageId
    };
    Response response = await handelPostWithUserToken("/transcribe", data);
    return TranscribeVoiceMessageRes.fromJson(response.data);
  }
}