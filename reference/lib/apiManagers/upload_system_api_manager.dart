import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:quick_share_app/apiManagers/upload_api_dto/get_upload_url_res.dart';
import 'package:quick_share_app/apiManagers/upload_api_dto/upload_draft_audio_res.dart';
import 'package:quick_share_app/utils/audio_utils.dart';
import 'abstractApiManager.dart';

final uploadApiManager = UploadApiManager(systemName: "UPLOAD_SERVER_URL");

class UploadApiManager extends AbstractApiManager {

  UploadApiManager({required String systemName}) : super(systemName: systemName);

  Future<GetUploadUrlRes> uploadStoryContent(File audioFile) async {
    final fileExtension = p.extension(audioFile.path).toLowerCase(); // e.g. .mp3, .m4a
    String? mimeType = lookupMimeType(audioFile.path);
    String? contentType;

    // Fallback if mimeType is null or unrecognized
    if (mimeType == null) {
      if (fileExtension == '.mp3') {
        mimeType = 'audio/mpeg';
        contentType = "mp3";
      } else if (fileExtension == '.m4a') {
        mimeType = 'audio/x-m4a'; // or 'audio/x-m4a' if required
        contentType = "m4a";
      } else {
        throw Exception('Unsupported audio file type');
      }
    } else {
      if(mimeType == "audio/mpeg") {
        contentType = "mp3";
      } else {
        mimeType = "audio/x-m4a";
        contentType = "m4a";
      }
    }

    var req = {
      "contentType": contentType
    };
    Response getUrlResponse = await handelPostWithUserToken("/story/content", req);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await audioFile.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': mimeType,
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<GetUploadUrlRes> uploadTransition(File transitionFile) async {
    final fileExtension = p.extension(transitionFile.path).toLowerCase(); // e.g. .mp3, .m4a
    String? mimeType = lookupMimeType(transitionFile.path);
    String? contentType;

    // Fallback if mimeType is null or unrecognized
    if (mimeType == null) {
      if (fileExtension == '.mp3') {
        mimeType = 'audio/mpeg';
        contentType = "mp3";
      } else if (fileExtension == '.m4a') {
        mimeType = 'audio/x-m4a'; // or 'audio/x-m4a' if required
        contentType = "m4a";
      } else {
        throw Exception('Unsupported audio file type');
      }
    } else {
      if(mimeType == "audio/mpeg") {
        contentType = "mp3";
      } else {
        mimeType = "audio/x-m4a";
        contentType = "m4a";
      }
    }

    var req = {
      "contentType": contentType
    };
    Response getUrlResponse = await handelPostWithUserToken("/transition", req);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await transitionFile.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': mimeType,
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<List<String>> uploadStoryImages(List<File> imageFiles) async {
    // Create one future per file. Future.wait preserves input order.
    final futures = List<Future<String>>.generate(imageFiles.length, (i) async {
      final file = imageFiles[i];

      // 1) Get a fresh signed URL for this file
      final Response getUrlResponse = await handelPostWithUserToken("/story/image", null);
      final getUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
      if (getUrlRes.code != "0000" || getUrlRes.data == null) {
        throw Exception("Failed to get upload URL (index $i): code=${getUrlRes.code}");
      }

      final String? signedUrl =
      (getUrlRes.data!.signedUrl ?? "");
      if (signedUrl == null || signedUrl.isEmpty) {
        throw Exception("Missing signed URL (index $i).");
      }

      // Prefer a clean/public URL from the API if provided; otherwise strip query from signed URL.
      final String finalUrl = getUrlRes.data!.publicUrl;

      // 2) Read bytes and upload via PUT
      final bytes = await file.readAsBytes();
      final response = await http.put(
        Uri.parse(signedUrl),
        headers: {
          // Keep as octet-stream unless your signed URL expects a specific content-type.
          'Content-Type': 'application/octet-stream',
        },
        body: bytes,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Upload failed (index $i): ${response.statusCode}');
      }

      // 3) Return the final accessible URL for this file
      return finalUrl;
    });

    // Run all uploads concurrently; order is preserved.
    return await Future.wait(futures);
  }

  String _stripQuery(String url) {
    final u = Uri.parse(url);
    return u.replace(query: "").toString();
  }

  Future<GetUploadUrlRes> uploadVoiceMessageAudio(File audioFile) async {
    Response getUrlResponse = await handelPostWithUserToken("/voiceMessage/audio", null);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await audioFile.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': 'audio/mpeg',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<GetUploadUrlRes> uploadChannelImage(File imageFile) async {
    Response getUrlResponse = await handelPostWithUserToken("/channel/image", null);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await imageFile.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<GetUploadUrlRes> uploadAudioLibraryAudio(File audioFile) async {
    Response getUrlResponse = await handelPostWithUserToken("/audioLibrary/audio", null);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await audioFile.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': 'audio/x-m4a',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<UploadDraftAudioRes> uploadDraftAudio(File audioFile) async {
    Response getUrlResponse = await handelPostWithUserToken("/draft/audioFile", null);
    UploadDraftAudioRes uploadUrlRes = UploadDraftAudioRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await audioFile.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.audioInfo!.signedUrl),
      headers: {
        'Content-Type': 'audio/x-m4a',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<GetUploadUrlRes> uploadDraftBlockInfo(File blockInfoFile, String draftId) async {
    Response getUrlResponse = await handelPostWithUserToken("/draft/$draftId/blockInfo", null);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await blockInfoFile.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<GetUploadUrlRes> uploadConcatVoiceMessage(File concatedMessage) async {
    Response getUrlResponse = await handelPostWithUserToken("/voiceMessage/concated", null);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await concatedMessage.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': 'audio/mpeg',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<GetUploadUrlRes> uploadPreVoiceMessage(File preMessage) async {
    Response getUrlResponse = await handelPostWithUserToken("/voiceMessage/pre", null);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await preMessage.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': 'audio/mpeg',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<GetUploadUrlRes> uploadAfterVoiceMessage(File afterMessage) async {
    Response getUrlResponse = await handelPostWithUserToken("/voiceMessage/after", null);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await afterMessage.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': 'audio/mpeg',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<GetUploadUrlRes> uploadBulletinImage(File imageFile) async {
    Response getUrlResponse = await handelPostWithUserToken("/liveBulletin/image", null);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await imageFile.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<GetUploadUrlRes> uploadBackgroundMp3Audio(File audioFile) async {
    Response getUrlResponse = await handelPostWithUserToken("/backgroundMusic/mp3", null);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await audioFile.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': 'audio/mpeg',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<GetUploadUrlRes> uploadBackgroundOggAudio(File audioFile) async {
    Response getUrlResponse = await handelPostWithUserToken("/backgroundMusic/ogg", null);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await audioFile.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': 'audio/ogg',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<GetUploadUrlRes> uploadPodcastStoreImage(File imageFile) async {
    Response getUrlResponse = await handelPostWithUserToken("/podcastStore/image", null);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await imageFile.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }

  Future<GetUploadUrlRes> uploadPodcastStoreLinkImage(File imageFile) async {
    Response getUrlResponse = await handelPostWithUserToken("/podcastStore/link", null);
    GetUploadUrlRes uploadUrlRes = GetUploadUrlRes.fromJson(getUrlResponse.data);
    if(uploadUrlRes.code != "0000") {
      return uploadUrlRes;
    }

    final bytes = await imageFile.readAsBytes();
    final response = await http.put(
      Uri.parse(uploadUrlRes.data!.signedUrl),
      headers: {
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Upload failed: ${response.statusCode}');
    }
    return uploadUrlRes;
  }
}