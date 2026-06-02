
import 'package:dio/dio.dart';
import 'package:quick_share_app/apiManagers/abstractApiManager.dart';
import 'package:quick_share_app/apiManagers/audio_library_api_dto/archive_audio_res.dart';
import 'package:quick_share_app/apiManagers/audio_library_api_dto/create_audio_res.dart';
import 'package:quick_share_app/apiManagers/audio_library_api_dto/find_audios_res.dart';

final audioLibraryApiManager = AudioLibraryApiManager(systemName: "AUDIO_LIBRARY_SERVER_URL");

class AudioLibraryApiManager extends AbstractApiManager {

  AudioLibraryApiManager({required String systemName}) : super(systemName: systemName);

  Future<CreateAudioRes> createAudio(String audioName, String audioUrl, String audioType) async {
    var postData = {
      "audioName": audioName,
      "audioUrl": audioUrl,
      "audioType": audioType
    };

    Response response = await handelPostWithUserToken("/audio", postData);
    return CreateAudioRes.fromJson(response.data);
  }

  Future<ArchiveAudioRes> archiveAudio(String audioId) async {
    Response response = await handelPostWithUserToken("/audio/$audioId/archive", null);
    return ArchiveAudioRes.fromJson(response.data);
  }

  Future<FindAudiosRes> findAudios(String audioType) async {
    Response response = await handelGetWithUserToken("/audioType/$audioType");
    return FindAudiosRes.fromJson(response.data);
  }
}
